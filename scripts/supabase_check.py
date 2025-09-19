#!/usr/bin/env python3
import os, psycopg2, datetime

# Use SUPABASE_CONN from supabase.env
conn = psycopg2.connect(os.environ["SUPABASE_CONN"])
cur = conn.cursor()
cur.execute("SELECT id, agent, action, timestamp FROM agent_logs ORDER BY timestamp DESC LIMIT 5;")
rows = cur.fetchall()

log_path = "/opt/infinity_x_one/logs/supabase_check.log"
with open(log_path, "a") as f:
    f.write(f"\n[{datetime.datetime.now()}] Supabase check ran:\n")
    for r in rows:
        f.write(str(r) + "\n")

print("✅ Supabase fetch test complete. Logged to supabase_check.log")
