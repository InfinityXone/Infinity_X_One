#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/opt/infinity_x_one/env/supabase.env"
LOG_DIR="/opt/infinity_x_one/logs"
LOG_FILE="$LOG_DIR/profit_balance_minutely.log"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
else
  echo "Missing env file: $ENV_FILE" >&2; exit 1;
fi

: "${SUPABASE_URL:?}"
: "${SUPABASE_SERVICE_ROLE_KEY:?}"

mkdir -p "$LOG_DIR"

URL="${SUPABASE_URL%/}/rest/v1/profit_ledger?select=amount"

JSON="$(curl -s \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  "$URL")"

TOTAL="$(printf '%s' "$JSON" | jq -r 'if length==0 then 0 else map(.amount) | add end')"
TS="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

printf '{"ts":"%s","total":%s}\n' "$TS" "$TOTAL" | tee -a "$LOG_FILE"
