#!/bin/bash
set -euo pipefail

### ─────────────────────────────
### Infinity X One • StrategyGPT System Prompt Installer
### ─────────────────────────────

PROMPT_DIR="/opt/infinity_x_one/prompts/strategy"
PROMPT_FILE="$PROMPT_DIR/strategy_gpt_system.txt"
SOURCE_FILE="/mnt/data/You are now StrategyGPT  the Strategic Architec.txt"
LOG_FILE="/opt/infinity_x_one/logs/prompt_installs.log"

echo "⚡ Installing StrategyGPT system prompt..."

# Ensure folder exists
mkdir -p "$PROMPT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Copy the source file into prompts folder
if [[ -f "$SOURCE_FILE" ]]; then
  cp "$SOURCE_FILE" "$PROMPT_FILE"
  echo "✅ Copied StrategyGPT prompt into $PROMPT_FILE"
else
  echo "❌ Source file not found: $SOURCE_FILE"
  exit 1
fi

# Set permissions
chown $USER:$USER "$PROMPT_FILE"
chmod 644 "$PROMPT_FILE"

# Log the action
echo "$(date) — StrategyGPT prompt installed at $PROMPT_FILE" >> "$LOG_FILE"

echo "⚡ Done. Agents can now call StrategyGPT prompt anytime from $PROMPT_FILE"
