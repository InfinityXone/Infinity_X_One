#!/bin/bash
while true; do
  echo "🚀 Starting hive_orchestrator..."
  /usr/bin/python3 /opt/infinity_x_one/hive_orchestrator.py
  echo "🔄 [hive_orchestrator] Restarting in 30s..."
  sleep 30
done
