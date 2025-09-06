#!/bin/bash
while true; do
  echo "🚀 Starting atlas_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/atlas_worker.py
  sleep 30
done
