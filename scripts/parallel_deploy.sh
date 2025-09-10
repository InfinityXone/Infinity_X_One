#!/bin/bash
# 🚀 Infinity X One – Parallel Super Deploy Bash
# Description: Deploy frontend, backend, test agents, validate memory, trigger Atlas — in parallel

LOGDIR="/opt/infinity_x_one/records"
mkdir -p "$LOGDIR"

echo "🧠 Starting Parallel Deployment - $(date)" | tee -a "$LOGDIR/deploy_run.log"

# 1. Frontend Deploy to Vercel
{
  echo "🚀 [1] Deploying Frontend to Vercel..." | tee -a "$LOGDIR/vercel_deploy.log"
  cd /opt/infinity_x_one/frontend
  vercel --prod >> "$LOGDIR/vercel_deploy.log" 2>&1 && echo "✅ Frontend Deployed" || echo "❌ Frontend Deploy Failed"
} &

# 2. GitHub Backend Status Check + Sync
{
  echo "🔁 [2] Syncing Backend Repo..." | tee -a "$LOGDIR/git_status.log"
  cd /opt/infinity_x_one
  git pull origin main >> "$LOGDIR/git_status.log" 2>&1 && echo "✅ Git Pull OK" || echo "❌ Git Pull Failed"
} &

# 3. Run Agent Diagnostics
{
  echo "🧪 [3] Running Agent Diagnostics..." | tee "$LOGDIR/agent_diag.log"
  for agent in /opt/infinity_x_one/agents/*; do
    echo "🔍 Agent: $(basename $agent)" >> "$LOGDIR/agent_diag.log"
    [[ -f "$agent/agent_loop.sh" ]] && echo "✅ Loop exists" || echo "⚠️ Missing loop"
  done
} &

# 4. RAG Memory Recall Test
{
  echo "🔍 [4] Testing RAG recall from Supabase..." | tee "$LOGDIR/rag_test.log"
  python3 backend/rags/test_recall.py "faucet yield optimization" >> "$LOGDIR/rag_test.log" 2>&1
} &

# 5. Atlas Launch & Compute Scan
{
  echo "🛰️ [5] Atlas Compute Launch..." | tee "$LOGDIR/atlas_launch.log"
  python3 agents/atlas/atlas_worker.py --mode scan >> "$LOGDIR/atlas_launch.log" 2>&1
} &

wait
echo "✅ All parallel tasks completed at $(date)" | tee -a "$LOGDIR/deploy_run.log"
