#!/bin/bash
while true; do
  echo "🚀 Starting nova_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/nova_api.py
  sleep 30
done
