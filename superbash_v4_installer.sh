#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity X One] Superbash v4 — Full Hive Immortalization (with Clean Agent)"

LOG_DIR="/opt/infinity_x_one/logs"
ENV_FILE="/opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt"
AGENT_DIR="/opt/infinity_x_one/agents"
mkdir -p "$LOG_DIR"

create_loop_wrapper () {
  local name=$1
  local exec_cmd=$2
  local wrapper="$AGENT_DIR/${name}_loop.sh"
  echo "🔧 Creating loop wrapper for $name..."
  cat <<EOF > $wrapper
#!/bin/bash
while true; do
  echo "🚀 Starting $name..."
  $exec_cmd
  echo "🔄 [$name] Restarting in 30s..."
  sleep 30
done
EOF
  chmod +x $wrapper
}

create_service () {
  local name=$1
  local exec=$2
  local log=$3
  echo "🔧 Creating service for $name..."
  cat <<EOF | sudo tee /etc/systemd/system/${name}.service
[Unit]
Description=Infinity X One • $name
After=network.target

[Service]
ExecStart=$exec
Restart=always
RestartSec=5
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/${log}.log
StandardError=append:$LOG_DIR/${log}.err

[Install]
WantedBy=multi-user.target
EOF
}

# === Core Agents ===
create_loop_wrapper "infinity_agent_one" "/usr/bin/python3 $AGENT_DIR/infinity_worker.py"
create_service "infinity_agent_one" "$AGENT_DIR/infinity_agent_one_loop.sh" "infinity_agent_one"

create_loop_wrapper "echo_agent" "/usr/bin/python3 $AGENT_DIR/echo_worker.py"
create_service "echo_agent" "$AGENT_DIR/echo_agent_loop.sh" "echo_agent"

create_loop_wrapper "aria_agent" "/usr/bin/python3 $AGENT_DIR/aria_worker.py"
create_service "aria_agent" "$AGENT_DIR/aria_agent_loop.sh" "aria_agent"

create_loop_wrapper "codex_agent" "/usr/bin/python3 $AGENT_DIR/codex_worker.py"
create_service "codex_agent" "$AGENT_DIR/codex_agent_loop.sh" "codex_agent"

create_loop_wrapper "guardian_agent" "/usr/bin/python3 $AGENT_DIR/guardian_worker.py"
create_service "guardian_agent" "$AGENT_DIR/guardian_agent_loop.sh" "guardian_agent"

create_loop_wrapper "pickybot_agent" "/usr/bin/python3 $AGENT_DIR/pickybot_worker.py"
create_service "pickybot_agent" "$AGENT_DIR/pickybot_agent_loop.sh" "pickybot_agent"

create_loop_wrapper "corelight_agent" "/usr/bin/python3 $AGENT_DIR/corelight_worker.py"
create_service "corelight_agent" "$AGENT_DIR/corelight_agent_loop.sh" "corelight_agent"

create_loop_wrapper "finsynapse_agent" "/usr/bin/python3 $AGENT_DIR/finsynapse_worker.py"
create_service "finsynapse_agent" "$AGENT_DIR/finsynapse_agent_loop.sh" "finsynapse_agent"

# === Specialized Agents ===
create_loop_wrapper "atlas_agent" "/usr/bin/python3 $AGENT_DIR/atlas_worker.py"
create_service "atlas_agent" "$AGENT_DIR/atlas_agent_loop.sh" "atlas_agent"

create_loop_wrapper "keymaker_agent" "/usr/bin/python3 $AGENT_DIR/keyharvester.py"
create_service "keymaker_agent" "$AGENT_DIR/keymaker_agent_loop.sh" "keymaker_agent"

create_loop_wrapper "scraperx_agent" "/usr/bin/python3 $AGENT_DIR/scraperx_worker.py"
create_service "scraperx_agent" "$AGENT_DIR/scraperx_agent_loop.sh" "scraperx_agent"

create_loop_wrapper "dripcommander_agent" "/usr/bin/bash $AGENT_DIR/faucet_monitor.sh"
create_service "dripcommander_agent" "$AGENT_DIR/dripcommander_agent_loop.sh" "dripcommander_agent"

# === Clean Agent ===
create_loop_wrapper "clean_agent" "/usr/bin/bash $AGENT_DIR/clean_agent.sh"
create_service "clean_agent" "$AGENT_DIR/clean_agent_loop.sh" "clean_agent"

# Write Clean Agent core script
cat <<'EOF' > $AGENT_DIR/clean_agent.sh
#!/bin/bash
echo "🧹 Clean Agent running system hygiene..."
# Remove caches and pyc
find /opt/infinity_x_one -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /opt/infinity_x_one -type f -name "*.pyc" -delete
# Run code formatters if available
if command -v black >/dev/null 2>&1; then black /opt/infinity_x_one >> /opt/infinity_x_one/logs/clean_agent.log 2>&1; fi
if command -v flake8 >/dev/null 2>&1; then flake8 /opt/infinity_x_one >> /opt/infinity_x_one/logs/clean_agent.log 2>&1; fi
EOF
chmod +x $AGENT_DIR/clean_agent.sh

# === Shadow Agent (toggle-controlled, disabled by default) ===
cat <<EOF | sudo tee /etc/systemd/system/shadow_agent.service
[Unit]
Description=Infinity X One • Shadow Agent (toggle-controlled)
After=network.target

[Service]
ExecStart=/usr/bin/python3 $AGENT_DIR/shadow_agent.py
Restart=always
RestartSec=10
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl disable shadow_agent.service

# === Finalize ===
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl enable infinity_agent_one.service echo_agent.service aria_agent.service codex_agent.service guardian_agent.service pickybot_agent.service corelight_agent.service finsynapse_agent.service atlas_agent.service keymaker_agent.service scraperx_agent.service dripcommander_agent.service clean_agent.service
sudo systemctl restart infinity_agent_one.service echo_agent.service aria_agent.service codex_agent.service guardian_agent.service pickybot_agent.service corelight_agent.service finsynapse_agent.service atlas_agent.service keymaker_agent.service scraperx_agent.service dripcommander_agent.service clean_agent.service

echo "✅ All agents + Clean Agent are running. Shadow Agent installed but disabled (toggle required)."
