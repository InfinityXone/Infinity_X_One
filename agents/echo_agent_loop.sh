#!/bin/bash
while true; do
  echo "🚀 Starting echo_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/echo_worker.py
  sleep 30
done
