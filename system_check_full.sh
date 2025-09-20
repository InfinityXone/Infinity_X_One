#!/bin/bash
# 🔍 Infinity X One — Full Parallel System Diagnostics
# Runs critical checks across ENV, systemd, Supabase, agent ports, folder tree, and Vercel config

echo ""
echo "🧠 Infinity X One — Parallel System Check (FULL)"
echo "====================================================="

# ENV
echo ""
echo "🔐 ENV File Check:"
ENV_FILE="$HOME/Infinity_X_One/env/system.env"
if [[ -f "$ENV_FILE" ]]; then
  echo "✅ system.env found at $ENV_FILE"
  grep -E "SUPABASE_URL|SUPABASE_SERVICE_ROLE_KEY|VERCEL_PROJECT_ID|AGENT_NAME|AGENT_PORT" "$ENV_FILE" | head -n 10
else
  echo "❌ system.env missing!"
fi

# Supabase
echo ""
echo "🌐 Supabase Connectivity Test:"
source "$ENV_FILE"
if [[ -z "$SUPABASE_URL" || -z "$SUPABASE_SERVICE_ROLE_KEY" ]]; then
  echo "⚠️ Supabase keys not loaded in ENV"
else
  curl -s -o /dev/null -w "%{http_code}\n" "$SUPABASE_URL/rest/v1/?apikey=$SUPABASE_SERVICE_ROLE_KEY"
fi

# Vercel project ID
echo ""
echo "📦 Vercel Project Info:"
grep -E "VERCEL_PROJECT_ID|VERCEL_ORG_ID" "$ENV_FILE" | sed 's/^/🔹 /'

# Agent Ports
echo ""
echo "💓 Agent Heartbeat Ports:"
for port in {8000..8110}; do
  curl -s "http://localhost:$port/heartbeat" | jq . 2>/dev/null && echo "✅ Port $port active" || echo "⚠️ Port $port inactive"
done

# Systemd agent statuses
echo ""
echo "⚙️ Systemd Agent Status:"
systemctl --user list-units --type=service | grep infinity_agent_ || echo "❌ No agent services found."

# Agent Files Check
echo ""
echo "📁 Agent Files Check:"
ls -1 ~/Infinity_X_One/agent_build_pack/agents/infinity_agent_*.py | wc -l | xargs -I{} echo "✅ {} agent files found"
head -n 5 ~/Infinity_X_One/agent_build_pack/agents/infinity_agent_2.py | grep -iE "FastAPI|uvicorn" || echo "⚠️ Agent missing FastAPI/uvicorn"

# Folder tree check
echo ""
echo "🗂️ Folder Tree Structure:"
tree -L 2 ~/Infinity_X_One | head -n 40

echo ""
echo "📦 Python Virtualenv Installed Packages (top 10):"
source ~/Infinity_X_One/venv/bin/activate
pip list | head -n 10

echo ""
echo "✅ System Check Complete."
