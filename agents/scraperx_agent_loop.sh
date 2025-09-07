#!/bin/bash
while true; do
  echo "🚀 Starting scraperx_agent..."
  /usr/bin/python3 /opt/infinity_x_one/agents/scraperx_worker.py
  sleep 30
done
