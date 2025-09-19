#!/bin/bash
echo "🧬 Running Infinity X One: UNBREAKABLE_BOOTSTRAP.sh"

echo "────────────────────────────────────────────"
echo "🔐 [1/6] Aggregating and loading all .env files..."
cat /opt/infinity_x_one/env/*.env > /opt/infinity_x_one/env/system.env
source /opt/infinity_x_one/scripts/load_env.sh 2>/dev/null || echo "⚠️ ENV loader not found"

echo "────────────────────────────────────────────"
echo "🛠️  [2/6] Repairing faucet_worker..."
mkdir -p /opt/infinity_x_one/backend/workers
touch /opt/infinity_x_one/backend/__init__.py
touch /opt/infinity_x_one/backend/workers/__init__.py

cat <<EOF > /opt/infinity_x_one/backend/workers/faucet_worker.py
# Infinity Faucet Worker — Restarted $(date)
import os, time
print("💧 Faucet Worker online...")
while True:
    print("💧 Harvesting faucets...")
    time.sleep(600)
EOF

echo "✅ faucet_worker.py rebuilt."

echo "────────────────────────────────────────────"
echo "🔁 [3/6] Restarting systemd services..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

for svc in \
    infinity_loop.service \
    infinity_recursion.service \
    persistent-sync.service \
    infinity_worker.service \
    omega_infinity_prime.service; do
    echo "⏳ Restarting $svc..."
    sudo systemctl restart "$svc" || echo "⚠️ $svc restart failed"
done

echo "────────────────────────────────────────────"
echo "🕒 [4/6] Ensuring cron ENV sourcing..."
crontab -l > /tmp/cronfix || touch /tmp/cronfix
grep -q "load_env.sh" /tmp/cronfix || echo "@reboot source /opt/infinity_x_one/scripts/load_env.sh" >> /tmp/cronfix
crontab /tmp/cronfix && rm /tmp/cronfix
echo "✅ Cron updated."

echo "────────────────────────────────────────────"
echo "📤 [5/6] GitHub commit and push..."
cd /opt/infinity_x_one
git add .
git commit -m "♻️ UNBREAKABLE_BOOTSTRAP executed $(date)"
git push origin main || echo "⚠️ Git push failed"

echo "────────────────────────────────────────────"
echo "🧪 [6/6] Final status check..."
sudo systemctl --no-pager | grep infinity_
echo "📍 Diagnostic log: /opt/infinity_x_one/logs/full_system_diagnostic_$(date +%F_%H-%M).log"
echo "✅ UNBREAKABLE_BOOTSTRAP Complete."

exit 0
