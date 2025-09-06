#!/bin/bash
while true; do
  echo "🚀 Starting infinity_agent_one..."
  /usr/bin/python3 /opt/infinity_x_one/agents/infinity_worker.py
  echo "🔄 [infinity_agent_one] Restarting in 30s..."
  sleep 30
done
