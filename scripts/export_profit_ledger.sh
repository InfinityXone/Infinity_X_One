#!/usr/bin/env bash
set -euo pipefail

OUTPUT_DIR="/mnt/data"
CSV_OUT="$OUTPUT_DIR/profit_ledger_export.csv"
XLSX_OUT="$OUTPUT_DIR/profit_ledger_export.xlsx"

# Load secrets
ENV_FILE="/opt/infinity_x_one/env/supabase.env"
source "$ENV_FILE"

# Fetch full profit_ledger JSON
JSON_OUT="$OUTPUT_DIR/profit_ledger.json"
curl -s \
  -H "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  "${SUPABASE_URL}/rest/v1/profit_ledger?select=*" \
  > "$JSON_OUT"

# Convert JSON → CSV + XLSX
python3 <<'PYCODE'
import pandas as pd, json

json_file = "/mnt/data/profit_ledger.json"
csv_file  = "/mnt/data/profit_ledger_export.csv"
xlsx_file = "/mnt/data/profit_ledger_export.xlsx"

with open(json_file) as f:
    data = json.load(f)

df = pd.DataFrame(data)

df.to_csv(csv_file, index=False)
df.to_excel(xlsx_file, index=False)

print(f"✅ Export complete")
print(f"CSV: {csv_file}")
print(f"XLSX: {xlsx_file}")
print(f"Rows: {len(df)}, Columns: {list(df.columns)}")
PYCODE
