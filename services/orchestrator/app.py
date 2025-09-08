from fastapi import FastAPI
from pydantic import BaseModel
import time, hashlib

app = FastAPI(title="Infinity Orchestrator Gateway")

class ApprovalRequest(BaseModel):
    action: str
    repo: str
    target: str

@app.get("/health")
async def health():
    return {"status": "ok", "app": "Infinity Orchestrator Gateway"}

@app.post("/agent/approve")
async def approve(req: ApprovalRequest):
    # Infinity Agent One "approval" logic
    payload = f"{req.action}-{req.repo}-{req.target}-{time.time()}"
    sig = hashlib.sha256(payload.encode()).hexdigest()
    return {
        "approved": True,
        "signature": f"IA1-{sig[:12]}",
        "timestamp": int(time.time())
    }
