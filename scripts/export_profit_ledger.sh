python3 <<'PYCODE'
import pandas as pd, json

json_file = "/mnt/data/profit_ledger.json"
csv_file  = "/mnt/data/profit_ledger_export.csv"
xlsx_file = "/mnt/data/profit_ledger_export.xlsx"

# Load JSON
with open(json_file) as f:
    data = json.load(f)
df = pd.DataFrame(data)

# --- Raw CSV + Excel ---
df.to_csv(csv_file, index=False)

# --- Build Summary ---
summary_frames = {}

# Total balance
total = df["amount"].sum()
summary_frames["Totals"] = pd.DataFrame([{"Total Balance": total, "Rows": len(df)}])

# By Faucet (top 10)
if "faucet" in df.columns:
    by_faucet = df.groupby("faucet")["amount"].sum().sort_values(ascending=False).head(10)
    summary_frames["By Faucet"] = by_faucet.reset_index()

# By Hour (top 20 slots)
if "ts" in df.columns:
    df["timestamp"] = pd.to_datetime(df["ts"], errors="coerce")
    df["hour_slot"] = df["timestamp"].dt.floor("H")
    by_hour = df.groupby("hour_slot")["amount"].sum().sort_index().head(20)
    summary_frames["By Hour"] = by_hour.reset_index()

# --- Write Excel with 2 sheets ---
with pd.ExcelWriter(xlsx_file, engine="openpyxl") as writer:
    df.to_excel(writer, sheet_name="Raw Data", index=False)
    for name, frame in summary_frames.items():
        frame.to_excel(writer, sheet_name=name, index=False)

print(f"✅ Export complete with summary")
print(f"CSV: {csv_file}")
print(f"XLSX: {xlsx_file} (Raw Data + Summary Sheets)")
print(f"Rows: {len(df)}, Columns: {list(df.columns)}")
PYCODE
