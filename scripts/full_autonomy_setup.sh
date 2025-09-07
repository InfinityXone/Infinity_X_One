#!/bin/bash
set -euo pipefail

BASE="/opt/infinity_x_one"
LOG_DIR="$BASE/logs"
ENV_FILE="$BASE/.env"
mkdir -p $LOG_DIR

echo "⚡ [Infinity X One] Beginning Full Autonomy Setup..."

# === Load ENV safely ===
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  set -a
  source "$ENV_FILE"
  set +a
  echo "✅ ENV loaded from $ENV_FILE"
else
  echo "❌ Missing ENV file at $ENV_FILE"
  exit 1
fi
