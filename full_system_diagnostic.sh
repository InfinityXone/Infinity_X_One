#!/bin/bash
# 🧠 Infinity X One – Omega Diagnostic Script
# Verifies full system automation from GPT to GitHub

LOG_FILE="/opt/infinity_x_one/logs/full_system_diagnostic_$(date +%Y-%m-%d_%H-%M-%S).log"
echo "🧪 Running Full System Diagnostic – $(date)" | tee $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "📁 [1] Folder + File Integrity" | tee -a $LOG_FILE
tree -a -I "node_modules|.git|venv|.next" /mnt/data >> $LOG_FILE
tree -a -I "node_modules|.git|venv|.next" /opt/infinity_x_one >> $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "🧠 [2] ENV Injection + Structure" | tee -a $LOG_FILE
cat /opt/infinity_x_one/env/system.env >> $LOG_FILE
echo "Environment Variables Loaded:"
env | grep -E "SUPABASE|AGENT|GITHUB|VERCEL|QSTASH|INNGEST" >> $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "🧩 [3] Systemd Services (Orchestration)" | tee -a $LOG_FILE
systemctl list-units --type=service --no-pager | grep infinity | tee -a $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "🕒 [4] CRON Jobs" | tee -a $LOG_FILE
crontab -l >> $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "🌐 [5] GitHub Status" | tee -a $LOG_FILE
cd /opt/infinity_x_one && git status >> $LOG_FILE
git log -n 5 --oneline >> $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "📡 [6] QStash/Webhook/Persistent Agents" | tee -a $LOG_FILE
grep -E "qstash|webhook|push|rotating|agent_loop" /opt/infinity_x_one/**/*.sh >> $LOG_FILE 2>/dev/null

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "🔍 [7] GPT Drop Verification (/mnt/data to /opt)" | tee -a $LOG_FILE
find /mnt/data -type f -mmin -10 >> $LOG_FILE
find /opt/infinity_x_one -type f -mmin -10 >> $LOG_FILE

echo "───────────────────────────────" | tee -a $LOG_FILE
echo "📤 [8] Supabase Connection + Table Check" | tee -a $LOG_FILE
curl -s -X GET "https://xzxkyrdelmbqlcucmzpx.supabase.co/rest/v1/profit_ledger" \
-H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
-H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" >> $LOG_FILE

echo "✅ DIAGNOSTIC COMPLETE — Logged to $LOG_FILE"
