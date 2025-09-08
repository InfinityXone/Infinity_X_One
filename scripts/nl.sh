#!/bin/bash
INPUT="$*"
INPUT_LOWER=$(echo "$INPUT" | tr '[:upper:]' '[:lower:]')

if [[ "$INPUT_LOWER" == *"gpt project"* || "$INPUT_LOWER" == *"gpt_projects"* ]]; then
  echo "🧠 Detected GPT project reference — triggering SuperPrompt factory"
  /opt/infinity_x_one/scripts/nano_superprompt.sh
else
  echo "❓ Unknown instruction. Try referencing GPT Projects."
fi
