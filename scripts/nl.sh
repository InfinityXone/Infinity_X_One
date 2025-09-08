#!/bin/bash
# ========================================
# NL.sh — Natural Language Cockpit for Infinity X One
# ========================================

QUERY="$*"
LOGFILE="/opt/infinity_x_one/records/nl_history.log"

echo "🧠 [NL.sh] Received request: $QUERY"
echo "$(date -u) | USER -> $QUERY" >> "$LOGFILE"

case "$QUERY" in

  # === Memory Recall ===
  *"recall "*)
    TOPIC=$(echo "$QUERY" | sed 's/recall //')
    if [ -f /opt/infinity_x_one/backend/agents/recall_agent.py ]; then
      python3 /opt/infinity_x_one/backend/agents/recall_agent.py "$TOPIC"
    else
      echo "⚠️ recall_agent.py not found"
    fi
    ;;

  # === Agent Test Hook ===
  *"test agent execution"*)
    if [ -f /opt/infinity_x_one/backend/agents/test_infinity_agent.py ]; then
      python3 /opt/infinity_x_one/backend/agents/test_infinity_agent.py
    else
      echo "⚠️ test_infinity_agent.py not found"
    fi
    ;;

  # === GitHub Push ===
  *"push repo"*)
    cd /opt/infinity_x_one || exit
    git add .
    git commit -m "🧠 Auto-sync: $QUERY"
    git push origin main || echo "⚠️ Git push failed"
    ;;

  # === Vercel Deploy ===
  *"deploy vercel"*)
    cd /opt/infinity_x_one/frontend || exit
    vercel --prod || echo "⚠️ Vercel deploy failed"
    ;;

  # === Git Logs ===
  *"show commit logs"*)
    git -C /opt/infinity_x_one log -5 --oneline
    ;;

  # === Default Case ===
  *)
    echo "⚠️ NL.sh: No mapping for: $QUERY"
    echo "$(date -u) | SYSTEM -> No mapping for: $QUERY" >> "$LOGFILE"
    ;;
esac
