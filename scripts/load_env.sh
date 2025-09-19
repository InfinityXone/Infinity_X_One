#!/bin/bash
ENV_FILE="/opt/infinity_x_one/env/system.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
  echo "✅ ENV loaded from $ENV_FILE"
else
  echo "❌ ENV file not found: $ENV_FILE"
fi
