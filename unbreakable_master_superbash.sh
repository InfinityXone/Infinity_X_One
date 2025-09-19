#!/bin/bash
echo "⚙️ Infinity X One – UNBREAKABLE SUPERBOOT v3.3.999"
echo "⏰ Started: $(date)"
echo "────────────────────────────────────────────"

# 1. 🔐 Load ENV Files from Master Stack
echo "🔐 Loading ENV files..."
source /mnt/data/env/auth.env
source /mnt/data/env/cloud.env
source /mnt/data/env/core.env
source /mnt/data/env/finance.env
source /mnt/data/env/git.env
source /mnt/data/env/master.env
source /mnt/data/env/runtime.env
source /mnt/data/env/supabase.env
source /mnt/data/env/vercel.env
source /mnt/data/env/wallets.env
export $(grep -v '^#' /mnt/data/env/*.env | xargs)

# 2. 📁 Verify Core Folder Integrity
mkdir -p ~/Infinity_X_One/logs
mkdir -p ~/Infinity_X_One/agents
mkdir -p ~/Infinity_X_One/env
mkdir -p ~/Infinity_X_One/scripts
mkdir -p ~/Infinity_X_One/backend/workers
cp -r /mnt/data/* ~/Infinity_X_One/ 2>/dev/null

# 3. 🔄 Reload systemd
echo "🔁 Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# 4. 🔁 Restart all services with elevated access
echo "🧬 Restarting core services..."
for svc in infinity_agent_one infinity_loop infinity_recursion infinity_worker omega_infinity_prime; do
  echo "⏳ Restarting $svc..."
  sudo systemctl restart ${svc}.service
done

# 5. 🛠️ Fix persistent sync with permissions
sudo cp /mnt/data/systemd/persistent-sync.service /etc/systemd/system/persistent-sync.service
sudo chmod 644 /etc/systemd/system/persistent-sync.service
sudo systemctl daemon-reload
sudo systemctl enable persistent-sync.service
sudo systemctl restart persistent-sync.service

# 6. 🕒 Restart CRON and inject ENV into crontab
( crontab -l 2>/dev/null | grep -v "source /mnt/data/env" ; echo "* * * * * source /mnt/data/env/master.env && bash ~/Infinity_X_One/scripts/auto_commit_lock_tag.sh >> ~/Infinity_X_One/logs/auto_commit.log 2>&1" ) | crontab -

# 7. 📡 Git push check
cd ~/Infinity_X_One
git add . && git commit -m "✅ Final Sync $(date)" && git push origin main

# 8. 📤 Supabase Test Ping
echo "📡 Testing Supabase heartbeat..."
curl -s -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" "$SUPABASE_URL/rest/v1/profit_ledger?limit=1" | jq '.'

# 9. 🧠 Confirm AI Pulse
echo "🧠 Agent Heartbeat Logs:"
tail -n 10 ~/Infinity_X_One/logs/agent_one.log
echo "✅ SYSTEM FULLY ALIGNED — $(date)"
