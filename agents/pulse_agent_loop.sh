#!/bin/bash
while true; do
  echo "🚀 Starting pulse_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/pulse_api.py
  sleep 30
done
