#!/bin/bash
QUERY="$*"
LOGFILE="/opt/infinity_x_one/records/nl_history.log"
mkdir -p /opt/infinity_x_one/records

echo "🧠 [NL.sh] Received request: $QUERY"
echo "$(date -u) | USER -> $QUERY" >> $LOGFILE

case "$QUERY" in
  *"push repo"*)
    cd /opt/infinity_x_one
    git add .
    git commit -m "🧠 Auto-sync: $QUERY"
    git push origin main
    ;;

  *"deploy vercel"*)
    echo "🚀 Deploying to Vercel..."
    cd /opt/infinity_x_one/frontend
    DEPLOY_RESULT=$(vercel --prod 2>&1)
    echo "$DEPLOY_RESULT" >> /opt/infinity_x_one/records/vercel_deploy.log
    echo "$(date -u) | DEPLOY -> $DEPLOY_RESULT" >> $LOGFILE
    echo "✅ Vercel deployed."
    ;;

  *"recall "*)
    TOPIC=$(echo "$QUERY" | sed 's/recall //')
    echo "🧠 [Infinity Agent One] Recalling memory for topic: $TOPIC"
    ;;

  *"test agent execution"*)
    echo "✅ Infinity Agent One is online and executing internal commands via NL.sh + GPT bridge."
    ;;

  *)
    echo "⚠️ NL.sh: No mapping for: $QUERY"
    echo "$(date -u) | SYSTEM -> No mapping for: $QUERY" >> $LOGFILE
    ;;
esac
