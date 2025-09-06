#!/bin/bash
while true; do
  echo "🚀 Starting clean_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/clean_worker.py
  sleep 30
done
