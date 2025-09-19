#!/bin/bash
set -euo pipefail
URL="https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore"
DEST="/mnt/data/test_autodownload_$(date +%s).txt"

curl -sL "$URL" -o "$DEST"
echo "✅ Auto-downloaded file from $URL into $DEST"
