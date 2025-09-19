#!/bin/bash
set -euo pipefail
echo "🧪 Running Infinity X One Systemwide Diagnostic... (🧠 NeoPulse-2025-001)"

NOW=$(date '+%Y-%m-%d %H:%M:%S')
LOG_DIR="/opt/infinity_x_one/logs"
mkdir -p "$LOG_DIR"
REPORT="$LOG_DIR/full_system_diagnostic_$NOW.log"

echo "📍 Diagnostic Timestamp: $NOW" | tee "$REPORT"
echo "──────────────────────────────────────────────" | tee -a "$REPORT"

### 1. CHECK ACTIVE SYSTEMD SERVICES
echo "🔌 [1/7] Systemd Service Status:" | tee -a "$REPORT"
systemctl list-units --type=service | grep infinity | tee -a "$REPORT"

### 2. CHECK ALL ACTIVE CRON JOBS
echo -e "\n🕒 [2/7] CRON Jobs (Current User):" | tee -a "$REPORT"
crontab -l | tee -a "$REPORT"

### 3. CHECK .ENV FILES + SUPABASE VARIABLES
echo -e "\n🔐 [3/7] Supabase ENV Variables (from supabase.env):" | tee -a "$REPORT"
if [ -f /opt/infinity_x_one/env/supabase.env ]; then
    source /opt/infinity_x_one/env/supabase.env
    echo "SUPABASE_URL: ${SUPABASE_URL}" | tee -a "$REPORT"
    echo "SUPABASE_SERVICE_ROLE_KEY: ${SUPABASE_SERVICE_ROLE_KEY:0:6}...***" | tee -a "$REPORT"
else
    echo "❌ supabase.env missing or unreadable." | tee -a "$REPORT"
fi

### 4. CHECK GIT STATUS
echo -e "\n🌐 [4/7] Git Repo Status:" | tee -a "$REPORT"
cd /opt/infinity_x_one
git status | tee -a "$REPORT"
git log -n 3 --pretty=format:"%h %ad %s" --date=local | tee -a "$REPORT"

### 5. CHECK LIVE LOGS (faucet + sync + agent loop)
echo -e "\n📄 [5/7] Last 20 Lines of faucet.log:" | tee -a "$REPORT"
tail -n 20 /opt/infinity_x_one/logs/faucet.log 2>/dev/null || echo "⚠️ faucet.log not found." | tee -a "$REPORT"

echo -e "\n📄 [6/7] Last 20 Lines of sync.log:" | tee -a "$REPORT"
tail -n 20 /opt/infinity_x_one/logs/sync.log 2>/dev/null || echo "⚠️ sync.log not found." | tee -a "$REPORT"

echo -e "\n📄 [7/7] Last 20 Lines of agent_one.log:" | tee -a "$REPORT"
tail -n 20 /opt/infinity_x_one/logs/agent_one.log 2>/dev/null || echo "⚠️ agent_one.log not found." | tee -a "$REPORT"

### 📬 Optional Push Results to Supabase (if available)
if command -v curl &>/dev/null && [[ -n "${SUPABASE_URL:-}" && -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]]; then
    curl -s -X POST "${SUPABASE_URL}/rest/v1/system_events" \
        -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"event_type\": \"diagnostic_report\", \"details\": \"System diagnostic run at $NOW.\"}"
    echo -e "\n📤 Supabase event log updated." | tee -a "$REPORT"
fi

echo -e "\n✅ Diagnostic Complete. Log saved to: $REPORT"
