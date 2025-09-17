#!/bin/bash
# Infinity X One - Auto Sync Pipeline v2
# Watches /mnt/data, syncs to /opt/infinity_x_one, pushes to GitHub, logs to Supabase

SRC_DIR="/mnt/data"
DEST_DIR="/opt/infinity_x_one"
LOG_FILE="/opt/infinity_x_one/logs/mnt_auto_sync.log"

# Supabase settings (set in your env files)
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_KEY="your-service-role-key"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

# Function: Log to Supabase
log_to_supabase() {
    local filename="$1"
    local sha="$2"
    curl -s -X POST "${SUPABASE_URL}/rest/v1/orchestrator_logs" \
        -H "apikey: ${SUPABASE_KEY}" \
        -H "Authorization: Bearer ${SUPABASE_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"filename\": \"${filename}\", \"commit_sha\": \"${sha}\", \"timestamp\": \"$(date -Iseconds)\"}" \
        >> "$LOG_FILE" 2>&1
}

# Start watching
inotifywait -m -r -e create -e moved_to -e close_write "$SRC_DIR" --format '%w%f' | while read FILE
do
    REL_PATH="${FILE#$SRC_DIR/}"
    DEST_PATH="$DEST_DIR/$REL_PATH"

    echo "[$(date)] New file detected: $REL_PATH" | tee -a "$LOG_FILE"

    # Ensure destination folder exists
    mkdir -p "$(dirname "$DEST_PATH")"

    # Copy file/folder over
    cp -r "$FILE" "$DEST_PATH"
    echo "[$(date)] Copied to: $DEST_PATH" | tee -a "$LOG_FILE"

    # Git commit & push (track everything, including untracked)
    cd "$DEST_DIR" || exit
    git add -A
    git commit -m "📦 AutoSync: Added/Updated $REL_PATH"
    git push origin main

    # Capture last commit SHA
    LAST_SHA=$(git rev-parse HEAD)
    echo "[$(date)] Git push complete for $REL_PATH (SHA: $LAST_SHA)" | tee -a "$LOG_FILE"

    # Log to Supabase
    log_to_supabase "$REL_PATH" "$LAST_SHA"
done
