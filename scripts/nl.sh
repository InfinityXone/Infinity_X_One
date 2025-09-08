#!/bin/bash
INPUT="$*"
INPUT_LOWER=$(echo "$INPUT" | tr '[:upper:]' '[:lower:]')

if [[ "$INPUT_LOWER" == *"gpt project"* || "$INPUT_LOWER" == *"gpt_projects"* ]]; then
  echo "🧠 Detected GPT project reference — triggering SuperPrompt factory"
  /opt/infinity_x_one/scripts/nano_superprompt.sh
else
  echo "❓ Unknown instruction. Try referencing GPT Projects."
fi
  "push repo"*) cd /opt/infinity_x_one && git add . && git commit -m "⏱ Auto-sync $(date)" && git push origin main ;;
  "deploy vercel"*) cd /opt/infinity_x_one && vercel --prod --yes ;;
  "supabase db list"*) supabase db list ;;
  "supabase db push"*) supabase db push ;;
