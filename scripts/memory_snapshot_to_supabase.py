import os
import hashlib
import datetime
import requests
from dotenv import load_dotenv

load_dotenv("/opt/infinity_x_one/env/supabase.env")

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_API_KEY = os.getenv("SUPABASE_SERVICE_KEY")
TABLE = "agent_memory_log"
MEMORY_FILE = "/opt/infinity_x_one/unified/unified_memory.txt"

def checksum(data):
    return hashlib.sha256(data.encode("utf-8")).hexdigest()

with open(MEMORY_FILE, "r") as f:
    memory_data = f.read()

data = {
    "agent": "UNIFIED_MEMORY_INJECTOR",
    "timestamp": datetime.datetime.utcnow().isoformat(),
    "memory_blob": memory_data,
    "checksum": checksum(memory_data),
    "origin": "unified_memory_injector"
}

headers = {
    "apikey": SUPABASE_API_KEY,
    "Authorization": f"Bearer {SUPABASE_API_KEY}",
    "Content-Type": "application/json"
}

response = requests.post(f"{SUPABASE_URL}/rest/v1/{TABLE}", json=data, headers=headers)

if response.status_code == 201:
    print("✅ Memory successfully uploaded to Supabase.")
else:
    print(f"❌ Upload failed: {response.status_code} → {response.text}")
