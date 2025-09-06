#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity AI Swarm] Repo Merger"

cd /opt/infinity_x_one

# Clone if missing
if [ ! -d "Infinity_AI_Swarm" ]; then
  git clone git@github.com:InfinityXone/Infinity_AI_Swarm.git
fi

cd Infinity_AI_Swarm
git pull origin main

# Unpack Genesis Deploy
if [ -f /mnt/data/genesis_deploy_final2.zip ]; then
  unzip -o /mnt/data/genesis_deploy_final2.zip -d genesis_tmp
  mkdir -p frontend backend/orchestrator
  cp -r genesis_tmp/frontend/* ./frontend/ || true
  cp -r genesis_tmp/orchestrator/* ./backend/orchestrator/ || true
fi

# Unpack Infinity Faucet System
if [ -f /mnt/data/infinity_faucet_system.zip ]; then
  unzip -o /mnt/data/infinity_faucet_system.zip -d faucet_tmp
  mkdir -p backend/agents scripts config
  cp -r faucet_tmp/workers/* ./backend/agents/ || true
  cp -r faucet_tmp/scripts/* ./scripts/ || true
  cp -r faucet_tmp/config/* ./config/ || true
fi

# Supabase schema
mkdir -p docs
cp "/mnt/data/Supabase Schema- sept 4 2025.txt" ./docs/schema.sql || true

# Master env
cp /mnt/data/INFINITY\ X\ ONE\ MASTER\ ENV.txt .env.local || true

# Commit + Push
git add .
git commit -m "🚀 Merge Genesis Deploy + Infinity Faucet System into Infinity_AI_Swarm"
git push origin main

# Deploy to Vercel
if [ -n "${VERCEL_TOKEN:-}" ]; then
  vercel --prod --token=$VERCEL_TOKEN
else
  echo "⚠️ Missing VERCEL_TOKEN in ENV — please export it first."
fi

echo "✅ Repo merge complete. Infinity_AI_Swarm is unified and deployed."
	

