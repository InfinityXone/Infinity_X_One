#!/usr/bin/env bash
set -euo pipefail
echo "🔧 Fixing systemd service and verifying setup..."

BASE="/opt/infinity_x_one"
SERVICE_FILE="/etc/systemd/system/hive_orchestrator.service"

# Check required files exist
for FILE in "$BASE/venv/bin/python" "$BASE/hive_orchestrator.py"; do
  if [ ! -f "$FILE" ]; then
    echo "❌ Missing file: $FILE"
  else
    echo "✅ Found: $FILE"
  fi
done

# Ensure the orchestrator script is executable
echo "Making orchestrator executable..."
sudo chmod +x "$BASE/hive_orchestrator.py" || true
sudo chown -R infinity-x-one:infinity-x-one "$BASE"

# Rewrite systemd service with absolute paths
echo "Rewriting systemd service..."
sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Infinity Hive Orchestrator
After=network.target

[Service]
WorkingDirectory=$BASE
ExecStart=$BASE/venv/bin/python $BASE/hive_orchestrator.py
Environment=PATH=$BASE/venv/bin:/usr/local/bin:/usr/bin:/bin
Restart=always
RestartSec=10
User=infinity-x-one

[Install]
WantedBy=multi-user.target
EOF

# Ensure logs directory exists
echo "Ensuring logs/ directory exists..."
sudo mkdir -p "$BASE/logs"
sudo chown infinity-x-one:infinity-x-one "$BASE/logs"

# Reload systemd and restart service
echo "Reloading systemd and restarting service..."
sudo systemctl daemon-reload
sudo systemctl restart hive_orchestrator.service

# Show current status
echo -e "\nService status:"
systemctl status hive_orchestrator.service --no-pager | head -n 10

# Final human-friendly health check
echo -e "\nPost-fix summary:"
ls -1 "$BASE"
echo "Cron jobs installed:"
crontab -l 2>/dev/null || echo "(none)"

echo "Git remote:"
cd "$BASE" && git remote -v

# Supabase connectivity test
echo -e "\nSupabase test:"
source "$BASE/venv/bin/activate"
python3 - <<'PY'
import os, sys
try:
    from supabase import create_client
    url, key = os.getenv("SUPABASE_URL"), os.getenv("SUPABASE_KEY")
    if not url or not key:
        print("  SUPABASE: URL or KEY missing.")
        sys.exit(0)
    sb = create_client(url, key)
    res = sb.table("agent_logs").select(count="exact").execute()
    print(f"  agent_logs count: {res.count}")
except Exception as e:
    print(f"  Supabase error: {e}")
PY

# Pause so terminal remains open—it avoids the script closing the terminal immediately.
echo -e "\nExecution complete. Press Enter to continue..."
read -r
