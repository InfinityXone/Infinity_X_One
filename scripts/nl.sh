#!/bin/bash
# ========================================
# NL.sh – Natural Language Cockpit for Infinity X One
# ========================================

QUERY="$*"
LOGFILE="/opt/infinity_x_one/records/nl_history.log"

echo "🧠 [NL.sh] Received request: $QUERY"
echo "$(date -u) | USER -> $QUERY" >> $LOGFILE

case "$QUERY" in

  # ==== LOCAL DESKTOP OPS ====
  *"list desktop"*|*"desktop files"*)
    ls -lh ~/Desktop
    ;;

  *"open file "*)
    FILE=$(echo "$QUERY" | cut -d' ' -f3-)
    xdg-open "$FILE" 2>/dev/null || echo "⚠️ Couldn't open $FILE"
    ;;

  *"search file "*)
    NAME=$(echo "$QUERY" | cut -d' ' -f3-)
    find ~ -iname "*$NAME*"
    ;;

  *"check processes"*)
    ps aux --sort=-%mem | head -n 20
    ;;

  *"system stats"*)
    echo "CPU / MEM / DISK:"
    top -bn1 | head -n 10
    df -h /
    ;;

  # ==== GIT/GITHUB ====
  *"push repo"*|*"update repo"*)
    cd /opt/infinity_x_one
    git add .
    git commit -m "🔄 Auto-sync via NL.sh: $QUERY"
    git push origin main
    ;;

  *"pull repo"*)
    cd /opt/infinity_x_one
    git pull origin main
    ;;

  # ==== VERCEL ====
  *"deploy vercel"*)
    cd /opt/infinity_x_one/frontend
    vercel --prod
    ;;

  # ==== SUPABASE ====
  *"supabase migrate"*)
    cd /opt/infinity_x_one/supabase
    supabase db push
    ;;

  *"supabase logs"*)
    cd /opt/infinity_x_one/supabase
    supabase logs
    ;;

  *"create RAG schema"*)
    cd /opt/infinity_x_one/supabase
    supabase db query < create_rag_schema.sql
    ;;

  # ==== INFINITY SYSTEM OPS ====
  *"list agents"*)
    ls -1 /opt/infinity_x_one/agents
    ;;

  *"start agent "*)
    AGENT=$(echo "$QUERY" | awk '{print $NF}')
    systemctl start $AGENT || echo "⚠️ No systemd unit for $AGENT"
    ;;

  *"stop agent "*)
    AGENT=$(echo "$QUERY" | awk '{print $NF}')
    systemctl stop $AGENT || echo "⚠️ No systemd unit for $AGENT"
    ;;

  *"restart infinity"*)
    systemctl restart infinity
    ;;

  *"show swarm logs"*)
    tail -n 50 /opt/infinity_x_one/logs/swarm_deploy.log
    ;;

  *"show echo logs"*)
    tail -n 50 /opt/infinity_x_one/records/agent_logs.json
    ;;

  # ==== REMOTE / MOBILE ====
  *"send to mobile "*)
    MSG=$(echo "$QUERY" | cut -d' ' -f3-)
    echo "📱 $MSG" >> /opt/infinity_x_one/records/mobile_bridge.log
    ;;

  *"read mobile"*)
    tail -n 20 /opt/infinity_x_one/records/mobile_bridge.log
    ;;

  # ==== VOICE ====
  *"voice on"*)
    echo "🎤 Voice interface active. Speak your commands."
    arecord -d 5 -f cd /tmp/nlsh_cmd.wav
    CMD=$(whisper --model base /tmp/nlsh_cmd.wav | tail -n 1)
    echo "Heard: $CMD"
    /opt/infinity_x_one/scripts/nl.sh "$CMD"
    ;;

  *"speak "*)
    TEXT=$(echo "$QUERY" | cut -d' ' -f2-)
    echo "$TEXT" | espeak
    ;;

  # ==== DEFAULT ====
  *)
    echo "⚠️ NL.sh: No mapping for: $QUERY"
    echo "$(date -u) | SYSTEM -> No mapping for: $QUERY" >> $LOGFILE
    ;;

esac
