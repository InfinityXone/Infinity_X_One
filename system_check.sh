#!/bin/bash
set -euo pipefail

echo "🧠 Infinity X One — Parallel System Check"
echo "========================================"

# 1. Systemd status
echo -e "\n🔍 Systemd Infinity Services:"
systemctl --user list-units --type=service | grep infinity || echo "⚠️ No infinity services found."

# 2. ENV check
echo -e "\n🔐 ENV Loaded Keys (first 10):"
head -n 10 ~/Infinity_X_One/env/system.env || echo "⚠️ system.env missing."

# 3. Heartbeat checks (Agent One + Agents 2–10)
echo -e "\n💓 Agent Heartbeats:"
for port in 8000 {8102..8110}; do
  echo -n "Port $port → "
  curl -s localhost:$port/heartbeat || echo "❌ no response"
done

# 4. Supabase connection test (requires curl + jq)
echo -e "\n🗄️ Supabase test (tables list):"
if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
  curl -s -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
       -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
       "$SUPABASE_URL/rest/v1/?apikey=$SUPABASE_SERVICE_ROLE_KEY" | jq . || echo "⚠️ Supabase connection failed."
else
  echo "⚠️ SUPABASE_URL or key not loaded in ENV."
fi

# 5. Recent logs
echo -e "\n📜 Agent One Logs (last 20):"
tail -n 20 ~/Infinity_X_One/logs/agent_one.log 2>/dev/null || echo "⚠️ No log file yet."

echo -e "\n✅ System check complete."
