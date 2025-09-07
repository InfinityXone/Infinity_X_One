from fastapi import FastAPI
import os, datetime, supabase

app = FastAPI()
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_KEY")
supabase_client = supabase.create_client(supabase_url, supabase_key)

@app.get("/heartbeat")
def heartbeat():
    return {"status": "Infinity Agent One online", "time": datetime.datetime.utcnow()}

@app.post("/task")
def run_task(task: dict):
    supabase_client.table("agent_tasks").insert(task).execute()
    return {"message": "Task accepted by Infinity Agent One", "task": task}
