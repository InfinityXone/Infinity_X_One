#!/bin/bash
WATCH_DIR="/mnt/data/infinity_x_one/scripts"
LOG_FILE="/mnt/data/infinity_x_one/logs/script_runner.log"

mkdir -p "$(dirname "$LOG_FILE")"
echo "🧪 [PRACTICE] Script runner active at $(date)" >> "$LOG_FILE"

inotifywait -m -e create --format "%w%f" "$WATCH_DIR" | while read NEWFILE; do
  echo "⚡ [PRACTICE] New script: $NEWFILE" >> "$LOG_FILE"
  chmod +x "$NEWFILE"
  "$NEWFILE" >> "$LOG_FILE" 2>&1
done
