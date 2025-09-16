#!/bin/bash
set -euo pipefail
SRC="/mnt/data"
DEST="/opt/infinity_x_one"

echo "🔁 Syncing GPT files from $SRC to $DEST ..."
rsync -av --ignore-existing "$SRC/" "$DEST/"
echo "✅ Sync complete."
