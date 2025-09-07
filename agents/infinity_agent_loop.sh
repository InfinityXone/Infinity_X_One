#!/bin/bash
while true; do
  echo "🚀 Starting infinity_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/infinity_worker.py
  sleep 30
done
