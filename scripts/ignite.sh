#!/usr/bin/env bash
set -euo pipefail
LOG_DIR="/mnt/gpt-projects/Infinity_X_One/logs"
mkdir -p $LOG_DIR
# Run CLI check before ignition
./scripts/cli_check.sh
echo "[IGNITE] Launching orchestrator + agents..."
# Start orchestrator
nohup python3 backend/orchestrator.py >> $LOG_DIR/orchestrator.log 2>&1 &
# Start agents
for AGENT in atlas_worker faucet_worker guardian_worker fin_synapse_worker pickybot_worker shadow_agent promptwriter_worker replicator_worker
do
  nohup python3 agents/$AGENT.py >> $LOG_DIR/$AGENT.log 2>&1 &
done
echo "[IGNITE] Infinity_X_One Swarm Online."
