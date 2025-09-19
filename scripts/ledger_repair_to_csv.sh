#!/usr/bin/env bash
set -euo pipefail

INPUT="/mnt/data/ledger 5 46 8 19.txt"
OUTPUT_DIR="/mnt/data"
CSV_OUT="$OUTPUT_DIR/ledger_fixed.csv"
XLSX_OUT="$OUTPUT_DIR/ledger_fixed.xlsx"
TMP_JSON="$OUTPUT_DIR/ledger_fixed.json"

# 1. Repair JSON (strip trailing commas, add closing ])
cp "$INPUT" "$TMP_JSON"
sed -i '$ s/},/}/' "$TMP_JSON"
if ! tail -n1 "$TMP_JSON" | grep -q "]"; then
  echo "]" >> "$TMP_JSON"
fi

# 2. Convert JSON → CSV + Excel
python3 <<'PYCODE'
import pandas as pd, json

json_file = "/mnt/data/ledger_fixed.json"
csv_file  = "/mnt/data/ledger_fixed.csv"
xlsx_file = "/mnt/data/ledger_fixed.xlsx"

with open(json_file) as f:
    data = json.load(f)

df = pd.DataFrame(data)

# Save outputs
df.to_csv(csv_file, index=False)
df.to_excel(xlsx_file, index=False)

print(f"✅ Export complete")
print(f"CSV: {csv_file}")
print(f"XLSX: {xlsx_file}")
print(f"Rows: {len(df)}, Columns: {list(df.columns)}")
PYCODE
