#!/bin/bash
set -euo pipefail

SEARCH_DIR="/opt/infinity_x_one"

echo "🔍 [Infinity X One] Agent & Worker Discovery"
echo "Scanning $SEARCH_DIR ..."

# Find likely agent / worker scripts
find "$SEARCH_DIR" \
  -type f \( -iname "*agent*" -o -iname "*worker*" -o -iname "*orchestrator*" -o -iname "*faucet*" -o -iname "*harvest*" -o -iname "*commander*" -o -iname "*scraper*" -o -iname "*atlas*" -o -iname "*keymaker*" \) \
  -printf "📂 %p\n"

echo "✅ Scan complete."
