#!/bin/bash
while true; do
  echo "🚀 Starting guardian_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/guardian_worker.py
  sleep 30
done
