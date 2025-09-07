#!/bin/bash
while true; do
  echo "🚀 Starting shadow_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/shadow_worker.py
  sleep 30
done
