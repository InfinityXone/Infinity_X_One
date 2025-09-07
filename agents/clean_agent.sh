#!/bin/bash
echo "🧹 Clean Agent running system hygiene..."
# Remove caches and pyc
find /opt/infinity_x_one -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find /opt/infinity_x_one -type f -name "*.pyc" -delete
# Run code formatters if available
if command -v black >/dev/null 2>&1; then black /opt/infinity_x_one >> /opt/infinity_x_one/logs/clean_agent.log 2>&1; fi
if command -v flake8 >/dev/null 2>&1; then flake8 /opt/infinity_x_one >> /opt/infinity_x_one/logs/clean_agent.log 2>&1; fi
