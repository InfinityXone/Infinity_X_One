#!/bin/bash
# Usage: source scripts/load_env.sh [dev|stage|prod]

ENV_NAME="$1"

if [ -z "$ENV_NAME" ]; then
  echo "❌ Please provide an environment name: dev, stage, or prod"
  echo "👉 Example: source scripts/load_env.sh dev"
  return 1 2>/dev/null || exit 1
fi

ENV_FILE="/opt/infinity_x_one/env/.env.${ENV_NAME}"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ ENV file not found: $ENV_FILE"
  return 1 2>/dev/null || exit 1
fi

echo "📦 Loading environment variables from: $ENV_FILE"
set -o allexport
source "$ENV_FILE"
set +o allexport

echo "✅ Environment variables loaded for [$ENV_NAME]"

