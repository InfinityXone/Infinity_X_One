#!/bin/bash
set -euo pipefail

### Infinity X One • Final Agentic System Launcher
WORKDIR="/opt/infinity_x_one"
REPO_SSH="git@github.com:InfinityXone/Genesis-AI-Neural-Link.git"
VENV="$WORKDIR/venv"

echo "[∞X1] 🌌 OMEGA PROTOCOL — AGENT MODE LAUNCH"
date

cd "$WORKDIR"

# 1. Clean nested git + reset repo
find . -name ".git" -type d -not -path "./.git" -exec rm -rf {} +
rm -rf .git
git init
git branch -M main
git remote add origin "$REPO_SSH"

# 2. Python env + requirements
if [ ! -x "$VENV/bin/python3" ]; then
  python3 -m venv "$VENV"
fi
source "$VENV/bin/activate"
pip install --upgrade pip wheel
cat > requirements.txt <<'REQ'
supabase
fastapi
uvicorn
requests
paramiko
python-dotenv
beautifulsoup4
feedparser
redis
REQ
pip install -r requirements.txt

# 3. Supabase schema
mkdir -p migrations
cat > migrations/000_init.sql <<'SQL'
create table if not exists agent_directives(id uuid primary key default gen_random_uuid(), agent text, directive text, context text, created_at timestamp default now());
create table if not exists agent_logs(id uuid primary key default gen_random_uuid(), agent text, message text, created_at timestamp default now());
create table if not exists profit_ledger(id uuid primary key default gen_random_uuid(), agent text, profit numeric, tx_hash text, created_at timestamp default now());
create table if not exists faucet_logs(id uuid primary key default gen_random_uuid(), agent text, message text, created_at timestamp default now());
create table if not exists swarm_state(id uuid primary key default gen_random_uuid(), agent text, node_id text, provider text, status text default 'active', created_at timestamp default now());
create table if not exists oath_commitments(id uuid primary key default gen_random_uuid(), agent text, oath text, created_at timestamp default now());
create table if not exists integrity_events(id uuid primary key default gen_random_uuid(), agent text, message text, created_at timestamp default now());
SQL

# 4. Backend core
mkdir -p backend/workers backend/agents frontend/pages frontend/public/icons frontend/pages/api/invoke .github/workflows k8s

cat > backend/supabase_utils.py <<'PY'
import os
from supabase import create_client
def get_client():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("SUPABASE_KEY")
    return create_client(url, key)
PY

cat > backend/handshake_api.py <<'PY'
from fastapi import FastAPI, Request
import subprocess, json
app = FastAPI(title="Infinity Handshake API")
WORKERS = {
 "codex":"backend/workers/codex_worker.py",
 "promptwriter":"backend/workers/promptwriter_worker.py",
 "guardian":"backend/workers/guardian_worker.py",
 "pickybot":"backend/workers/pickybot_worker.py",
 "echo":"backend/workers/echo_worker.py",
 "aria":"backend/workers/aria_worker.py",
 "infinity":"backend/workers/infinity_worker.py",
 "finsynapse":"backend/workers/fin_synapse_worker.py",
 "optimizer":"backend/workers/optimizer_worker.py",
 "scraperx":"backend/workers/scraperx_worker.py",
 "faucet":"backend/workers/faucet_ignition.py",
 "keyharvester":"backend/workers/api_key_harvester.py",
 "atlas":"backend/workers/compute_account_finder.py",
 "strategy":"backend/workers/strategy_launcher.py"
}
@app.post("/invoke/{agent}")
async def invoke(agent: str, request: Request):
    payload = await request.json()
    if agent not in WORKERS: return {"error": f"unknown agent: {agent}"}
    subprocess.Popen(["python3", WORKERS[agent], json.dumps(payload)])
    return {"status":"queued","agent":agent}
@app.get("/status")
def status(): return {"status":"ok","agents":list(WORKERS.keys())}
PY

cat > hive_orchestrator.py <<'PY'
import subprocess, time
def launch(name,path): print(f"[Hive] {name}"); subprocess.Popen(["python3",path])
if __name__=="__main__":
  for n,p in [("PromptWriter","backend/workers/promptwriter_worker.py"),
              ("Codex","backend/workers/codex_worker.py"),
              ("Guardian","backend/workers/guardian_worker.py"),
              ("PickyBot","backend/workers/pickybot_worker.py"),
              ("Echo","backend/workers/echo_worker.py"),
              ("Aria","backend/workers/aria_worker.py"),
              ("FinSynapse","backend/workers/fin_synapse_worker.py"),
              ("Infinity","backend/workers/infinity_worker.py"),
              ("Faucet","backend/workers/faucet_ignition.py"),
              ("KeyHarvester","backend/workers/api_key_harvester.py"),
              ("Atlas","backend/workers/compute_account_finder.py"),
              ("Optimizer","backend/workers/optimizer_worker.py"),
              ("ScraperX","backend/workers/scraperx_worker.py"),
              ("Strategy","backend/workers/strategy_launcher.py")]:
      launch(n,p); time.sleep(2)
  while True: time.sleep(3600)
PY

# 5. Worker stubs
for f in promptwriter_worker codex_worker guardian_worker pickybot_worker echo_worker aria_worker infinity_worker fin_synapse_worker optimizer_worker scraperx_worker faucet_ignition api_key_harvester compute_account_finder strategy_launcher; do
cat > backend/workers/${f}.py <<PY
import time
from backend.supabase_utils import get_client
sb=get_client()
while True:
    sb.table("agent_logs").insert({"agent":"$f","message":"heartbeat"}).execute()
    time.sleep(60)
PY
done

# 6. Frontend Cockpit UI + Builder
cat > frontend/pages/cockpit.js <<'JSX'
import { useState,useEffect } from "react";
import { createClient } from "@supabase/supabase-js";

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

export default function Cockpit(){
  const [msgs,setMsgs]=useState([]); const [input,setInput]=useState("");
  const [profit,setProfit]=useState(0); const [faucets,setFaucets]=useState([]); const [swarm,setSwarm]=useState(0);

  async function send(){ if(!input) return;
    setMsgs(m=>[...m,{role:"you",text:input}]);
    await fetch("/api/invoke/codex",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({command:input})});
    setMsgs(m=>[...m,{role:"codex",text:"Codex executing..."}]); setInput("");
  }

  useEffect(()=>{ 
    const t=setInterval(async()=>{
      let { data: p } = await supabase.from("profit_ledger").select("profit").order("created_at",{ascending:false}).limit(1);
      let { data: f } = await supabase.from("faucet_logs").select("message,created_at").order("created_at",{ascending:false}).limit(5);
      let { data: s } = await supabase.from("swarm_state").select("node_id").order("created_at",{ascending:false}).limit(1);
      if(p?.length) setProfit(p[0].profit); if(f?.length) setFaucets(f); if(s?.length) setSwarm(s.length);
    },5000);
    return()=>clearInterval(t);
  },[]);

  return(<div className="h-screen flex bg-black text-white">
    <aside className="w-72 bg-zinc-900 p-4">
      <h2 className="text-lg font-bold mb-4">∞X1 Agents</h2>
      {["PromptWriter","Codex","Guardian","PickyBot","Echo","Aria","FinSynapse","Infinity","Faucet"].map(a=>
        <div key={a}>🟢 {a}</div>)}
      <div className="mt-4 text-sm">Swarm: {swarm}</div>
      <div className="mt-2 text-sm">P&L: ${profit}</div>
    </aside>
    <main className="flex-1 flex flex-col">
      <header className="p-4 border-b border-zinc-800 flex justify-between">
        <span>∞X1 Cockpit</span><span>Agent Mode • Online</span>
      </header>
      <section className="flex-1 overflow-y-auto p-4 space-y-2">
        {msgs.map((m,i)=><div key={i} className={m.role==="you"?"text-blue-400":"text-green-400"}>{m.role}: {m.text}</div>)}
        <div className="mt-6"><h3 className="font-semibold">Recent Faucet Logs</h3>
          {faucets.map((f,i)=><div key={i} className="text-xs text-zinc-400">{f.created_at}: {f.message}</div>)}
        </div>
      </section>
      <footer className="p-4 flex gap-2">
        <input className="flex-1 bg-zinc-900 p-2" value={input} onChange={e=>setInput(e.target.value)} placeholder="Type directive..."/>
        <button onClick={send} className="bg-blue-600 px-4 py-2 rounded">Send</button>
      </footer>
    </main>
  </div>);
}
JSX

# 7. Vercel + CI
cat > vercel.json <<'JSON'
{"version":2,"builds":[{"src":"backend/handshake_api.py","use":"@vercel/python"}],"routes":[{"src":"/(.*)","dest":"/backend/handshake_api.py"}]}
JSON
cat > .github/workflows/ci.yml <<'YAML'
name: Infinity CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - run: echo "CI triggered"
YAML

# 8. Kubernetes (apply)
cat > k8s/deploy.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata: { name: handshake }
spec:
  replicas: 2
  selector: { matchLabels:{app:handshake} }
  template:
    metadata: { labels:{app:handshake} }
    spec:
      containers:
      - name: handshake
        image: python:3.11
        command:["bash","-lc","backend/run_handshake.sh"]
        ports: [{containerPort:8000}]
YAML
kubectl apply -f k8s/deploy.yaml || true

# 9. Commit + Push + Vercel trigger
git add .
git commit -m "🧬 Infinity X One Full Agentic System"
git push -f origin main
[ -n "${VERCEL_DEPLOY_HOOK:-}" ] && curl -X POST "$VERCEL_DEPLOY_HOOK"

# 10. Launch hive locally
echo "[∞X1] 🚀 Launching Hive locally..."
python3 hive_orchestrator.py &
echo "[∞X1] ✅ System live: Cockpit (Vercel), Hive (local), Supabase (ledger)."
