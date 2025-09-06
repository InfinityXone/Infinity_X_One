#!/bin/bash
while true; do
  echo "🚀 Starting agent_mode_master..."
  /opt/infinity_x_one/agent_mode_master.sh
  echo "🔄 [agent_mode_master] Restarting in 30s..."
  sleep 30
done
