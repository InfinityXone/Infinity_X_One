#!/bin/bash
while true; do
  echo "🚀 Starting prism_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/prism_api.py
  sleep 30
done
