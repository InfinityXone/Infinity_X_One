#!/bin/bash
while true; do
  echo "🚀 Starting pickybot_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/pickybot_worker.py
  sleep 30
done
