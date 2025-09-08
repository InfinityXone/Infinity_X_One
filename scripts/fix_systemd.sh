#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Bringing systemd service back online..."

BASE="/opt/infinity_x_one"
SERVICE_FILE="/etc/systemd/system/hive_orchestrator.service"

# Step 1: Validate essential components
echo "• Verifying critical files exist..."
for FILE in "$BASE/venv/bin/python" "$BASE/hive_orchestrator.py"; do
  if [ -f "$FILE" ]; then
    echo "  ✅ Found: $FILE"
  else
    echo "  ❌ Missing: $FILE"
    exit 1
  fi
done

# Step 2: Ensure script is executable
echo "• Ensuring orchestrator is executable..."
sudo chmod +x "$BASE/hive_orchestrator.py"
sudo chown -R infinity-x-one:infinity-x-one "$BASE"

# Step 3: (Re)write systemd unit with absolute paths
echo "• Rewriting systemd service..."
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

# Step 4: Make logs/ available
echo "• Ensuring logs directory exists..."
sudo mkdir -p "$BASE/logs"
sudo chown infinity-x-one:infinity-x-one "$BASE/logs"

# Step 5: Reload and restart orchestrator
echo "• Reloading systemd & restarting service..."
sudo systemctl daemon-reload
sudo systemctl restart hive_orchestrator.service

# Step 6: Display limited service status
echo -e "\n• Service Status:"
systemctl status hive_orchestrator.service --no-pager | head -n 10

# Step 7: Summary diagnostics
echo -e "\n• Project root listing:"
ls -1 "$BASE"
echo -e "\n• Cron jobs installed:"
crontab -l 2>/dev/null || echo "  (none)"

echo -e "\n• Git remote configuration:"
cd "$BASE"
git remote -v

echo -e "\n• Supabase connectivity check:"
source "$BASE/venv/bin/activate"
python3 - <<'PY'
import os
try:
    from supabase import create_client
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not (url and key):
        print("  ❗ SUPABASE_URL or SUPABASE_KEY not set")
        exit(0)
    sb = create_client(url, key)
    res = sb.table("agent_logs").select(count="exact").execute()
    print(f"  agent_logs count: {res.count}")
except Exception as e:
    print(f"  Supabase error: {e}")
PY

# Final Step: Wait for any key — Terminal stays open
read -n 1 -s -r -p $'\nExecution complete. Press any key to exit...\n'
echo
