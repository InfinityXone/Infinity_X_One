#!/usr/bin/env bash
# Launch Infinity X One gateway and optionally schedule cron jobs.

set -e
source venv/bin/activate

echo "Starting Infinity X One Gateway..."
python3 backend/gateway.py &
GATEWAY_PID=$!
echo "Gateway PID: $GATEWAY_PID"

# Install crons from config/crons.yaml if supercronic is available
if command -v supercronic >/dev/null 2>&1; then
  echo "Installing cron schedule..."
  cat config/crons.yaml | while read -r line; do
    : # placeholder; actual cron integration can be done via supercronic
  done
fi

wait $GATEWAY_PID