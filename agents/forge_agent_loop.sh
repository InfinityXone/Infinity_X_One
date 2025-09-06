#!/bin/bash
while true; do
  echo "🚀 Starting forge_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/forge_api.py
  sleep 30
done
