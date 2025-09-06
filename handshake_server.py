from fastapi import FastAPI, Request
import os, time, supabase

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY")
client = supabase.create_client(SUPABASE_URL, SUPABASE_KEY)

app = FastAPI()

@app.post("/directive")
async def directive(req: Request):
    data = await req.json()
    client.table("agent_directives").insert({
        "agent": data.get("agent","all"),
        "command": data.get("command"),
        "ts": time.time()
    }).execute()
    return {"status":"ok","echo":data}

@app.get("/status")
async def status():
    return {"handshake":"NeoPulse-2025-001","ts":time.time()}
