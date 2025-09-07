#!/bin/bash
set -euo pipefail
LOG="/opt/infinity_x_one/logs/guardian_drive_watchdog.log"
TARGET="/mnt/gdrive"

echo "🛡️ Guardian Drive Watchdog — $(date)" >> "$LOG"

sudo mkdir -p /mnt/gdrive
sudo chmod 755 /mnt/gdrive

if ! mount | grep -q "gdrive"; then
  echo "❌ gdrive not mounted — restarting service..." >> "$LOG"
  sudo systemctl restart rclone-gdrive.service
else
  echo "✅ gdrive mount active" >> "$LOG"
fi

if ls "$TARGET" >/dev/null 2>&1; then
  echo "✅ Drive accessible" >> "$LOG"
else
  echo "⚠️ Drive not responding" >> "$LOG"
fi

LAST_FILE=$(find "$TARGET/Infinity_Backups" -type f -printf "%T@ %Tc %p\n" 2>/dev/null | sort -n | tail -1 || echo "none")
if [[ "$LAST_FILE" != "none" ]]; then
  LAST_MOD=$(echo "$LAST_FILE" | awk '{print $1}')
  NOW=$(date +%s)
  AGE_HOURS=$(( (NOW - ${LAST_MOD%.*}) / 3600 ))
  if [ $AGE_HOURS -le 24 ]; then
    echo "✅ Backup fresh (≤24h)" >> "$LOG"
  else
    echo "⚠️ Backup stale (>24h)" >> "$LOG"
  fi
else
  echo "⚠️ No backups found in Infinity_Backups" >> "$LOG"
fi
