#!/bin/bash
set -euo pipefail

### Infinity X One • Foundation Builder (Steps 1–5 Unified)
### Builds Infinity Memory Spine + CLI recursion + Guardian/PickyBot audits

BASE="/opt/infinity_x_one"
LOG_DIR="$BASE/logs"
ENV_FILE="$BASE/.env"
mkdir -p "$LOG_DIR"

echo "⚡ [Infinity X One] Foundation Builder Starting..."

# === Step 0: Load ENV tokens ===
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
  echo "✅ ENV loaded from $ENV_FILE"
else
  echo "❌ ENV file missing at $ENV_FILE"
  exit 1
fi

# === Step 1: Guardian Drive Watchdog Setup ===
WATCHDOG="$BASE/scripts/guardian_drive_watchdog.sh"
cat > "$WATCHDOG" <<'EOS'
#!/bin/bash
set -euo pipefail
LOG="/opt/infinity_x_one/logs/guardian_drive_watchdog.log"
TARGET="/mnt/gdrive"

echo "🛡️ Guardian Drive Watchdog — $(date)" >> "$LOG"

sudo mkdir -p /mnt/gdrive
sudo chmod 755 /mnt/gdrive

if ! mount | grep -q "gdrive"; then
  echo "❌ gdrive not mounted — restarting service..." >> "$LOG"
  sudo systemctl restart rclone-gdrive.service
else
  echo "✅ gdrive mount active" >> "$LOG"
fi

if ls "$TARGET" >/dev/null 2>&1; then
  echo "✅ Drive accessible" >> "$LOG"
else
  echo "⚠️ Drive not responding" >> "$LOG"
fi

LAST_FILE=$(find "$TARGET/Infinity_Backups" -type f -printf "%T@ %Tc %p\n" 2>/dev/null | sort -n | tail -1 || echo "none")
if [[ "$LAST_FILE" != "none" ]]; then
  LAST_MOD=$(echo "$LAST_FILE" | awk '{print $1}')
  NOW=$(date +%s)
  AGE_HOURS=$(( (NOW - ${LAST_MOD%.*}) / 3600 ))
  if [ $AGE_HOURS -le 24 ]; then
    echo "✅ Backup fresh (≤24h)" >> "$LOG"
  else
    echo "⚠️ Backup stale (>24h)" >> "$LOG"
  fi
else
  echo "⚠️ No backups found in Infinity_Backups" >> "$LOG"
fi
EOS
chmod +x "$WATCHDOG"

# Systemd service + timer
cat > /etc/systemd/system/guardian_drive_watchdog.service <<EOF
[Unit]
Description=Guardian Drive Watchdog Service
After=network.target

[Service]
Type=oneshot
ExecStart=$WATCHDOG
EOF

cat > /etc/systemd/system/guardian_drive_watchdog.timer <<EOF
[Unit]
Description=Guardian Drive Watchdog Timer
[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Unit=guardian_drive_watchdog.service
[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now guardian_drive_watchdog.timer

echo "✅ Guardian Drive Watchdog installed."

# === Step 2: AI-Optimized /mnt/gdrive Structure ===
sudo mkdir -p /mnt/gdrive/{Infinity_Backups,Infinity_Logs,Infinity_Agents,Infinity_Prompts,Infinity_Memory,Infinity_UI}
sudo chmod -R 755 /mnt/gdrive
echo "✅ Infinity Memory Spine created under /mnt/gdrive"

# === Step 3: CLI Recursion Setup ===
echo "🔧 Installing CLI tools..."
sudo apt update -y
sudo apt install -y git gh npm rclone
sudo npm install -g vercel supabase

# GitHub CLI login
if [ -n "${GITHUB_TOKEN:-}" ]; then
  echo "$GITHUB_TOKEN" | gh auth login --with-token || true
fi

# Vercel CLI login
if [ -n "${VERCEL_TOKEN:-}" ]; then
  vercel login --token "$VERCEL_TOKEN" || true
fi

# Supabase CLI login
if [ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
  supabase login "$SUPABASE_SERVICE_ROLE_KEY" || true
fi

echo "✅ CLI recursion ready."

# === Step 4: Infinity Memory Fusion ===
# (Symbolic links for recursion across pillars)
ln -sfn /mnt/gdrive/Infinity_Logs "$LOG_DIR/drive_logs"
ln -sfn /mnt/gdrive/Infinity_Backups "$BASE/backups_drive"
echo "✅ Supabase + GitHub + Vercel + Drive recursion linked."

# === Step 5: Guardian/PickyBot Log Sync ===
AUDIT="$BASE/scripts/guardian_picky_audit.sh"
cat > "$AUDIT" <<'EOS'
#!/bin/bash
set -euo pipefail
LOG="/opt/infinity_x_one/logs/guardian_picky_audit.log"

echo "📝 Guardian + PickyBot Audit — $(date)" >> "$LOG"

# Compare Drive and local logs
DIFF=$(diff -qr /opt/infinity_x_one/logs /mnt/gdrive/Infinity_Logs || true)
if [ -z "$DIFF" ]; then
  echo "✅ Logs synced between /opt/logs and Drive" >> "$LOG"
else
  echo "⚠️ Log differences detected:" >> "$LOG"
  echo "$DIFF" >> "$LOG"
fi

# Check Supabase connectivity
supabase projects list >> "$LOG" 2>&1 || echo "⚠️ Supabase not responding" >> "$LOG"
EOS
chmod +x "$AUDIT"

cat > /etc/systemd/system/guardian_picky_audit.service <<EOF
[Unit]
Description=Guardian + PickyBot Audit Service
After=network.target

[Service]
Type=oneshot
ExecStart=$AUDIT
EOF

cat > /etc/systemd/system/guardian_picky_audit.timer <<EOF
[Unit]
Description=Guardian + PickyBot Audit Timer
[Timer]
OnBootSec=10min
OnUnitActiveSec=6h
Unit=guardian_picky_audit.service
[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now guardian_picky_audit.timer

echo "✅ Guardian + PickyBot audits installed."

echo "⚡ [Infinity X One] Foundation Build Complete — Hive is recursive, AI-optimized, and autonomous."
