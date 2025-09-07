#!/bin/bash
while true; do
  echo "🚀 Starting flux_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/flux_api.py
  sleep 30
done
