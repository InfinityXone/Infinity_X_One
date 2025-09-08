#!/bin/bash
# NL.sh — Natural Language Shell for Infinity X One

QUERY="\$*"
LOGFILE="/opt/infinity_x_one/records/nl_history.log"
echo "🧠 [NL.sh] Received request: \$QUERY"
echo "\$(date -u) | USER -> \$QUERY" >> \$LOGFILE

case "\$QUERY" in
  *"recall "*)
    TOPIC=\$(echo "\$QUERY" | sed 's/recall //')
    /opt/infinity_x_one/backend/agents/recall_agent.py "\$TOPIC"
    ;;

  *"test agent execution"*)
    /opt/infinity_x_one/backend/agents/test_infinity_agent.py
    ;;

  *"push repo"*)
    cd /opt/infinity_x_one
    git add .
    git commit -m "🧠 Auto-sync: \$QUERY"
    git push origin main || echo "⚠️ Git push failed"
    ;;

  *"deploy vercel"*)
    cd /opt/infinity_x_one/frontend
    vercel --prod || echo "⚠️ Vercel deploy failed"
    ;;

  *"show commit logs"*)
    git -C /opt/infinity_x_one log -5 --oneline
    ;;

  *)
    echo "⚠️ NL.sh: No mapping for: \$QUERY"
    echo "\$(date -u) | SYSTEM -> No mapping for: \$QUERY" >> \$LOGFILE
    ;;
esac
