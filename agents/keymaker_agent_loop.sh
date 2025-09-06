#!/bin/bash
while true; do
  echo "🚀 Starting keymaker_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/keymaker_worker.py
  sleep 30
done
