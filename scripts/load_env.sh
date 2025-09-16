#!/bin/bash
ENV_NAME=$1
if [ -z "$ENV_NAME" ]; then
  echo "Usage: source scripts/load_env.sh [dev|stage|prod]"
  return 1
fi
if [ -f "/opt/infinity_x_one/env/.env.$ENV_NAME" ]; then
  export \$(grep -v '^#' /opt/infinity_x_one/env/.env.$ENV_NAME | xargs)
  echo "🔑 Loaded /opt/infinity_x_one/env/.env.$ENV_NAME"
else
  echo "❌ Missing /opt/infinity_x_one/env/.env.$ENV_NAME"
fi
