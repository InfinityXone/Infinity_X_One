#!/usr/bin/env bash
set -euo pipefail

# Hardcode Supabase keys (from your env file)
SUPABASE_URL="https://xzxkyrdelmbqlcucmzpx.supabase.co"
SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6eGt5cmRlbG1icWxjdWNtenB4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTE0MTE0NSwiZXhwIjoyMDcwNzE3MTQ1fQ.WwE58HIpKZ8O9a244yt79jNuSyThkYODGCPL7a7u2_w"

NOW=$(date -u +%s)

# Pull most recent row
LAST_TS=$(curl -s \
  -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
  "$SUPABASE_URL/rest/v1/profit_ledger?select=ts&order=ts.desc&limit=1" \
  | jq -r '.[0].ts')

if [[ "$LAST_TS" == "null" || -z "$LAST_TS" ]]; then
  echo "❌ No rows in ledger"
  exit 1
fi

LAST_TS_EPOCH=$(date -d "$LAST_TS" +%s)
AGE=$(( NOW - LAST_TS_EPOCH ))

if (( AGE > 600 )); then
  echo "⚠️ Ledger has not updated in $AGE seconds ($((AGE/60)) minutes)"
else
  echo "✅ Ledger updated $AGE seconds ago"
fi
