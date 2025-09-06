#!/bin/bash
while true; do
  echo "🚀 Starting aria_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/aria_worker.py
  sleep 30
done
