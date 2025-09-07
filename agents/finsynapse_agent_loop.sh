#!/bin/bash
while true; do
  echo "🚀 Starting finsynapse_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/finsynapse_worker.py
  sleep 30
done
