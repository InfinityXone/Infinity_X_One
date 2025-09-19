#!/bin/bash
echo "⚙️ UNBREAKABLE SUPERBOOT v3.3.999 — $(date)"
echo "────────────────────────────────────────────"

# ✅ 1. LOAD ENV FILES (Corrected Path)
echo "🔐 Loading all .env files from /mnt/data/"
for envfile in /mnt/data/*.env; do
  echo "→ Loading $envfile"
  source "$envfile"
done
export $(grep -v '^#' /mnt/data/*.env | xargs)

# ✅ 2. REPO MIGRATION TO ~/Infinity_X_One (if not already done)
echo "📁 Ensuring repo exists in ~/Infinity_X_One"
mkdir -p ~/Infinity_X_One/logs
cp -rn /opt/infinity_x_one/* ~/Infinity_X_One/ 2>/dev/null
ln -sf ~/Infinity_X_One /opt/infinity_x_one

# ✅ 3. SYSTEMD RELOAD & RESTART (with sudo)
echo "🔁 Reloading and restarting services..."
sudo -S systemctl daemon-reexec
sudo -S systemctl daemon-reload
for svc in infinity_agent_one infinity_loop infinity_recursion infinity_worker omega_infinity_prime; do
  echo "⏳ Restarting $svc..."
  sudo -S systemctl restart ${svc}.service
done

# ✅ 4. CRON FIX — use user crontab
echo "🕒 Fixing cron jobs..."
( crontab -l 2>/dev/null | grep -v 'auto_commit_lock_tag' ; echo "*/5 * * * * source /mnt/data/master.env && bash ~/Infinity_X_One/scripts/auto_commit_lock_tag.sh >> ~/Infinity_X_One/logs/auto_commit.log 2>&1" ) | crontab -

# ✅ 5. GIT SYNC
echo "📤 Git Push Status:"
cd ~/Infinity_X_One
git add . && git commit -m "✅ Unbreakable Boot Sync $(date)" && git push origin main

# ✅ 6. SUPABASE TEST PING
echo "📡 Testing Supabase with key: $SUPABASE_SERVICE_ROLE_KEY"
curl -s -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" "$SUPABASE_URL/rest/v1/profit_ledger?limit=1" | jq '.' || echo "❌ Supabase query failed"

# ✅ 7. AGENT ONE HEARTBEAT
echo "🧠 Agent One Logs:"
tail -n 10 ~/Infinity_X_One/logs/agent_one.log

echo "✅ BOOT COMPLETE — SYSTEM IS UNBREAKABLE"
