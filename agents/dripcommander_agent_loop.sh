#!/bin/bash
while true; do
  echo "🚀 Starting dripcommander_agent..."
  /usr/bin/bash /opt/infinity_x_one/agents/faucet_monitor.sh
  echo "🔄 [dripcommander_agent] Restarting in 30s..."
  sleep 30
done
