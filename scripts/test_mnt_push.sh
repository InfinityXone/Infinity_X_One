#!/usr/bin/env bash
set -euo pipefail

PROJECT="/mnt/gpt-project"
cd "$PROJECT"

echo "🚀 Requesting Infinity Agent One approval via Gateway..."
APPROVAL=$(curl -s -X POST http://localhost:8000/agent/approve \
  -H "Content-Type: application/json" \
  -d '{"action":"push_repo","repo":"'$PROJECT'","target":"github+vercel"}')

APPROVED=$(echo "$APPROVAL" | jq -r '.approved')

if [[ "$APPROVED" == "true" ]]; then
  echo "✅ Infinity Agent One approved. Proceeding with push + deploy..."
  
  # Initialize Git repo if missing
  if [ ! -d ".git" ]; then
    git init
    git branch -M main
    git remote add origin git@github.com:InfinityXone/gpt-project.git
  fi
  
  git add .
  git commit -m "Autonomous commit from Infinity Agent One approval" || echo "ℹ️ Nothing new to commit."
  git push -u origin main
  
  echo "🚀 Deploying to Vercel..."
  vercel --prod --yes --confirm --token "$VERCEL_TOKEN"
  
  echo "🎉 Test complete — Repo pushed & deployed with agent approval."
else
  echo "❌ Infinity Agent One denied approval."
  exit 1
fi

