#!/bin/bash
while true; do
  echo "🚀 Starting agent_orchestrator..."
  /usr/bin/python3 /opt/infinity_x_one/agent_orchestrator.py
  echo "🔄 [agent_orchestrator] Restarting in 30s..."
  sleep 30
done
