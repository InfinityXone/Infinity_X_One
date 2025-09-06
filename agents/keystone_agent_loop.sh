#!/bin/bash
while true; do
  echo "🚀 Starting keystone_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/keystone_api.py
  sleep 30
done
