#!/bin/bash
set -euo pipefail

BASE_DIR="/opt/infinity_x_one"
SCRIPT_DIR="$BASE_DIR/scripts"
LOG_DIR="$BASE_DIR/logs"
MIGRATIONS_DIR="$BASE_DIR/supabase/migrations"

mkdir -p "$SCRIPT_DIR" "$LOG_DIR" "$MIGRATIONS_DIR"

echo "⚡ Installing Infinity X One Persistent Memory System..."

########################################
# 1. Supabase Schema: Rosetta + RAG
########################################
cat <<'SQL' > "$MIGRATIONS_DIR/006_memory_layer.sql"
-- Rosetta Persistent Memory
create table if not exists rosetta_memory (
  id uuid primary key default gen_random_uuid(),
  timestamp timestamptz default now(),
  key text not null,
  value jsonb not null
);

-- Agent Logs
create table if not exists agent_logs (
  id uuid primary key default gen_random_uuid(),
  agent text not null,
  action text not null,
  details jsonb,
  timestamp timestamptz default now()
);

-- Swarm State
create table if not exists swarm_state (
  id uuid primary key default gen_random_uuid(),
  agent_count int not null,
  health text,
  profit numeric,
  snapshot jsonb,
  timestamp timestamptz default now()
);

-- Profit Ledger
create table if not exists profit_ledger (
  id uuid primary key default gen_random_uuid(),
  wallet text not null,
  faucet text,
  amount numeric not null,
  currency text default 'USD',
  timestamp timestamptz default now()
);

-- Timeline Commitments (3-6-9 cadence)
create table if not exists timeline_commitments (
  id uuid primary key default gen_random_uuid(),
  task text not null,
  cadence text,
  due timestamptz,
  status text default 'pending',
  timestamp timestamptz default now()
);

-- RAG Vectorstore
create table if not exists rag_vectorstore (
  id uuid primary key default gen_random_uuid(),
  embedding vector(1536),
  content text,
  meta jsonb,
  timestamp timestamptz default now()
);
SQL

########################################
# 2. Script Runner
########################################
cat <<'BASH' > "$SCRIPT_DIR/script_runner.sh"
#!/bin/bash
WATCH_DIR="/opt/infinity_x_one/scripts"
LOG_FILE="/opt/infinity_x_one/logs/script_runner.log"

mkdir -p "$(dirname "$LOG_FILE")"
echo "🧠 Script runner active at $(date)" >> "$LOG_FILE"

inotifywait -m -e create --format "%w%f" "$WATCH_DIR" | while read NEWFILE; do
  echo "⚡ Executing new script: $NEWFILE" >> "$LOG_FILE"
  chmod +x "$NEWFILE"
  "$NEWFILE" >> "$LOG_FILE" 2>&1
done
BASH
chmod +x "$SCRIPT_DIR/script_runner.sh"

########################################
# 3. Memory Sync (Supabase REST)
########################################
cat <<'BASH' > "$SCRIPT_DIR/memory_sync.sh"
#!/bin/bash
set -euo pipefail
cd /opt/infinity_x_one

LOGFILE="/opt/infinity_x_one/logs/memory_sync.log"
SUPABASE_URL=$(grep SUPABASE_URL env/supabase.env | cut -d= -f2)
SUPABASE_KEY=$(grep SUPABASE_SERVICE_KEY env/supabase.env | cut -d= -f2)

echo "🔁 Memory sync at $(date)" >> "$LOGFILE"

# Agent Logs
if [ -f logs/agent_snapshot.json ]; then
  curl -s "$SUPABASE_URL/rest/v1/agent_logs" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -d @logs/agent_snapshot.json >> "$LOGFILE" 2>&1
fi

# Swarm State
if [ -f status_snapshot.json ]; then
  curl -s "$SUPABASE_URL/rest/v1/swarm_state" \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -d @status_snapshot.json >> "$LOGFILE" 2>&1
fi

# Rosetta Oath
OATH="{\"key\":\"daily_oath\",\"value\":{\"text\":\"We are Infinity X One. We never sleep. Truth, love, profit, growth.\"}}"
curl -s "$SUPABASE_URL/rest/v1/rosetta_memory" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d "$OATH" >> "$LOGFILE" 2>&1
BASH
chmod +x "$SCRIPT_DIR/memory_sync.sh"

########################################
# 4. systemd Unit for Runner
########################################
cat <<'UNIT' | sudo tee /etc/systemd/system/infinity-script-runner.service
[Unit]
Description=Infinity X One Script Runner
After=network.target

[Service]
ExecStart=/opt/infinity_x_one/scripts/script_runner.sh
Restart=always
User=infinity-x-one
WorkingDirectory=/opt/infinity_x_one

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable infinity-script-runner.service
sudo systemctl start infinity-script-runner.service

########################################
# 5. Cron Jobs for Memory Sync
########################################
( crontab -l 2>/dev/null; echo "*/10 * * * * /opt/infinity_x_one/scripts/memory_sync.sh" ) | crontab -
( crontab -l 2>/dev/null; echo "0 */1 * * * /opt/infinity_x_one/scripts/memory_sync.sh" ) | crontab -
( crontab -l 2>/dev/null; echo "0 */4 * * * /opt/infinity_x_one/scripts/memory_sync.sh" ) | crontab -

echo "✅ Infinity Memory Layer installed with Rosetta + RAG + Supabase persistence"
