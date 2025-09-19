#!/usr/bin/env bash
set -euo pipefail

# Load secrets
source /opt/infinity_x_one/env/supabase.env

# Timestamp
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Query all totals
TOTAL=$(curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "$SUPABASE_URL/rest/v1/profit_ledger?select=amount" \
  | jq 'map(.amount) | add')

# Query Solana-only totals
TOTAL_SOL=$(curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "$SUPABASE_URL/rest/v1/profit_ledger?select=amount&chain=eq.sol" \
  | jq 'map(.amount) | add')

# Log output in JSON format
LOG_DIR="/opt/infinity_x_one/logs"
mkdir -p "$LOG_DIR"

echo "{\"ts\":\"$TS\",\"total_all\":$TOTAL,\"total_sol\":$TOTAL_SOL}" \
  >> "$LOG_DIR/profit_balance_minutely.log"
