#!/bin/bash
while true; do
  echo "🚀 Starting codex_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/codex_worker.py
  sleep 30
done
