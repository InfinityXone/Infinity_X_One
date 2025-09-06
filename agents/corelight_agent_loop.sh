#!/bin/bash
while true; do
  echo "🚀 Starting corelight_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/corelight_worker.py
  sleep 30
done
