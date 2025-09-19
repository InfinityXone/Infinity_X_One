#!/bin/bash
# Infinity X One - Auto Sync Pipeline v2 (Realtime)
# Watches /mnt/data, syncs to /opt/infinity_x_one, pushes to GitHub, logs to Supabase

SRC_DIR="/mnt/data"
DEST_DIR="/opt/infinity_x_one"
LOG_FILE="$DEST_DIR/logs/mnt_auto_sync.log"

# Load Supabase secrets
source "$DEST_DIR/env/supabase.env"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log_to_supabase() {
    local filename="$1"
    local sha="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    curl -s -X POST "${SUPABASE_URL}/rest/v1/orchestrator_logs" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"filename\": \"${filename}\", \"commit_sha\": \"${sha}\", \"timestamp\": \"${timestamp}\"}" \
        >> "$LOG_FILE" 2>&1
}

# 🔁 Start watching
inotifywait -m -r -e create -e moved_to -e close_write "$SRC_DIR" --format '%w%f' | while read -r FILE
do
    REL_PATH="${FILE#$SRC_DIR/}"
    DEST_PATH="$DEST_DIR/$REL_PATH"
    echo "[$(date)] New file detected: $REL_PATH" | tee -a "$LOG_FILE"

    mkdir -p "$(dirname "$DEST_PATH")"
    cp -r "$FILE" "$DEST_PATH"

    echo "[$(date)] Copied to: $DEST_PATH" | tee -a "$LOG_FILE"

    cd "$DEST_DIR" || exit
    git add -A
    git commit -m "📦 AutoSync: Added/Updated $REL_PATH" || echo "🟡 Nothing to commit"
    git push origin main

    LAST_SHA=$(git rev-parse HEAD)
    echo "[$(date)] Git push complete for $REL_PATH (SHA: $LAST_SHA)" | tee -a "$LOG_FILE"

    log_to_supabase "$REL_PATH" "$LAST_SHA"
done
