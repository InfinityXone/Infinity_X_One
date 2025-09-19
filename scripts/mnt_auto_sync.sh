#!/bin/bash
# Infinity X One - Multi-Agent AutoSync Pipeline
# Watches /mnt/data for ALL agents, syncs to /opt/infinity_x_one, pushes to GitHub

SRC_DIR="/mnt/data"
DEST_DIR="/opt/infinity_x_one"
LOG_FILE="$DEST_DIR/logs/mnt_auto_sync.log"

mkdir -p "$(dirname "$LOG_FILE")"

inotifywait -m -r -e create -e moved_to -e close_write "$SRC_DIR" --format '%w%f' | while read FILE
do
    REL_PATH="${FILE#$SRC_DIR/}"
    DEST_PATH="$DEST_DIR/$REL_PATH"

    echo "[$(date)] New file detected: $REL_PATH" | tee -a "$LOG_FILE"

    # Ensure destination folder exists
    mkdir -p "$(dirname "$DEST_PATH")"

    # Copy file/folder
    cp -r "$FILE" "$DEST_PATH"

    echo "[$(date)] Copied to: $DEST_PATH" | tee -a "$LOG_FILE"

    # Git commit + push
    cd "$DEST_DIR" || exit
    git add "$REL_PATH"
    git commit -m "📦 AutoSync: Added/Updated $REL_PATH by multi-agent pipeline"
    git push origin main

    echo "[$(date)] Git push complete for $REL_PATH" | tee -a "$LOG_FILE"
done
