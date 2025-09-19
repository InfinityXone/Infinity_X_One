#!/bin/bash
set -euo pipefail

BASE="$HOME/Infinity_X_One"
PACK="$BASE/agent_build_pack"
mkdir -p $PACK/{agents,scripts,systemd,supabase/migrations,logs,env}

echo "🚀 Infinity X One — Superbash Layer A"
echo "📂 Build directory: $PACK"

#######################################
# 1. ENV Segregation + Merge
#######################################
cat <<'EOF' > $PACK/scripts/merge_env.sh
#!/bin/bash
TARGET="$HOME/Infinity_X_One/env/system.env"
echo "# Auto-merged $(date)" > "$TARGET"
for file in core.env faucet.env atlas.env guardian.env wallets.env; do
  [ -f "$HOME/Infinity_X_One/env/$file" ] && {
    echo -e "\n# === $file ===" >> "$TARGET"
    grep -v '^#' "$HOME/Infinity_X_One/env/$file" | grep '=' >> "$TARGET"
  }
done
chmod 600 "$TARGET"
EOF
chmod +x $PACK/scripts/merge_env.sh
bash $PACK/scripts/merge_env.sh

# Auto-load on login + CRON
grep -q "system.env" ~/.bashrc || echo 'source ~/Infinity_X_One/env/system.env' >> ~/.bashrc
( crontab -l 2>/dev/null | grep -v 'BASH_ENV=' ; echo "BASH_ENV=$HOME/Infinity_X_One/env/system.env" ) | crontab -

#######################################
# 2. API Agent Template (FastAPI + Headless Browser)
#######################################
cat <<'EOF' > $PACK/agents/api_agent_template.py
import os, asyncio, logging, json
from fastapi import FastAPI
import uvicorn
from supabase import create_client
from pyppeteer import launch

# ENV load
ENV_PATH = os.path.expanduser("~/Infinity_X_One/env/system.env")
if os.path.exists(ENV_PATH):
    for line in open(ENV_PATH):
        if "=" in line:
            k,v=line.strip().split("=",1); os.environ[k]=v

SUPABASE_URL=os.environ.get("SUPABASE_URL")
SUPABASE_KEY=os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase = create_client(SUPABASE_URL,SUPABASE_KEY)

app=FastAPI()

async def browser_task(url="https://example.com"):
    browser = await launch(headless=True,args=["--no-sandbox"])
    page = await browser.newPage()
    await page.goto(url)
    title = await page.title()
    await browser.close()
    return title

@app.get("/heartbeat")
def heartbeat():
    data={"agent":os.environ.get("AGENT_NAME","Unknown"),"status":"alive"}
    supabase.table("agent_status").insert(data).execute()
    return data

@app.get("/task")
async def task(url: str):
    title=await browser_task(url)
    payload={"agent":os.environ.get("AGENT_NAME","Unknown"),"action":"browse","details":{"url":url,"title":title}}
    supabase.table("agent_logs").insert(payload).execute()
    return payload

if __name__=="__main__":
    port=int(os.environ.get("PORT","8100"))
    uvicorn.run(app,host="0.0.0.0",port=port)
EOF

#######################################
# 3. Infinity Agent One (orchestrator)
#######################################
cat <<'EOF' > $PACK/agents/infinity_agent_one.py
import os, logging, json
from fastapi import FastAPI
import uvicorn
from supabase import create_client

ENV_PATH=os.path.expanduser("~/Infinity_X_One/env/system.env")
if os.path.exists(ENV_PATH):
    for line in open(ENV_PATH):
        if "=" in line:
            k,v=line.strip().split("=",1); os.environ[k]=v

SUPABASE_URL=os.environ.get("SUPABASE_URL")
SUPABASE_KEY=os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
supabase=create_client(SUPABASE_URL,SUPABASE_KEY)

logfile=os.path.expanduser("~/Infinity_X_One/logs/agent_one.log")
logging.basicConfig(filename=logfile,level=logging.INFO,format="%(asctime)s %(message)s")

app=FastAPI(title="Infinity Agent One")

@app.get("/heartbeat")
def heartbeat():
    data={"agent":"AgentOne","status":"alive"}
    supabase.table("agent_status").insert(data).execute()
    return data

@app.get("/spawn/{agent}")
def spawn(agent:str):
    evt={"agent":"AgentOne","event_type":"spawn","payload":{"target":agent}}
    supabase.table("system_events").insert(evt).execute()
    return {"status":"spawning","agent":agent}

if __name__=="__main__":
    uvicorn.run(app,host="0.0.0.0",port=8000)
EOF

#######################################
# 4. Agent Spawner (2–10)
#######################################
cat <<'EOF' > $PACK/agents/agent_spawner.py
import os, subprocess

AGENTS={2:"faucet_hunter",3:"api_key_harvester",4:"fin_synapse",
        5:"guardian",6:"pickybot",7:"echo",8:"aria",
        9:"corelight",10:"atlas"}

for num,name in AGENTS.items():
    unit=f"""[Unit]
Description=Infinity Agent {num} - {name}
After=network.target

[Service]
ExecStart=python3 %h/Infinity_X_One/agent_build_pack/agents/api_agent_template.py
Environment=AGENT_NAME=Agent{num}
Environment=PORT=81{num:02d}
Restart=always
WorkingDirectory=%h/Infinity_X_One/agent_build_pack/agents
EnvironmentFile=%h/Infinity_X_One/env/system.env
StandardOutput=append:%h/Infinity_X_One/logs/agent_{num}.log
StandardError=append:%h/Infinity_X_One/logs/agent_{num}.err

[Install]
WantedBy=default.target
"""
    path=os.path.expanduser(f"~/.config/systemd/user/infinity_agent_{num}.service")
    os.makedirs(os.path.dirname(path),exist_ok=True)
    open(path,"w").write(unit)
    subprocess.run(["systemctl","--user","enable",f"infinity_agent_{num}.service"])
print("✅ Agents 2–10 registered in systemd")
EOF

#######################################
# 5. Systemd unit for Agent One
#######################################
mkdir -p ~/.config/systemd/user
cat <<'EOF' > ~/.config/systemd/user/infinity_agent_one.service
[Unit]
Description=Infinity Agent One
After=network.target

[Service]
ExecStart=python3 %h/Infinity_X_One/agent_build_pack/agents/infinity_agent_one.py
Restart=always
EnvironmentFile=%h/Infinity_X_One/env/system.env
WorkingDirectory=%h/Infinity_X_One/agent_build_pack/agents
StandardOutput=append:%h/Infinity_X_One/logs/agent_one.log
StandardError=append:%h/Infinity_X_One/logs/agent_one.err

[Install]
WantedBy=default.target
EOF

#######################################
# 6. Supabase schema migrations
#######################################
cat <<'EOF' > $PACK/supabase/migrations/001_layer_a.sql
create table if not exists agent_status (
  id bigint generated by default as identity primary key,
  agent text, status text, wallet text,
  last_heartbeat timestamp default now()
);
create table if not exists system_events (
  id bigint generated by default as identity primary key,
  ts timestamp default now(),
  agent text, event_type text, payload jsonb
);
create table if not exists swarm_state (
  id bigint generated by default as identity primary key,
  ts timestamp default now(),
  active_agents int, details jsonb
);
create table if not exists agent_logs (
  id bigint generated by default as identity primary key,
  ts timestamp default now(),
  agent text, action text, details jsonb
);
create table if not exists rosetta_memory (
  id bigint generated by default as identity primary key,
  ts timestamp default now(),
  memory jsonb
);
EOF

#######################################
# 7. CRON jobs
#######################################
cat <<'EOF' > $PACK/scripts/swarm_cron.txt
*/10 * * * * curl -s localhost:8000/heartbeat
*/30 * * * * echo "system health tick" >> ~/Infinity_X_One/logs/health.log
0 */4 * * * echo "agent eval tick" >> ~/Infinity_X_One/logs/eval.log
@daily echo '{"memory":"snapshot"}' | psql $SUPABASE_URL -c "insert into rosetta_memory(memory) values(jsonb_build_object('snapshot', now()));"
EOF
crontab $PACK/scripts/swarm_cron.txt

#######################################
# 8. Done
#######################################
echo "✅ Layer A build complete."
echo "👉 Next: cp -r $PACK/* ~/Infinity_X_One/ && systemctl --user daemon-reexec && systemctl --user daemon-reload && systemctl --user enable --now infinity_agent_one.service && python3 ~/Infinity_X_One/agent_build_pack/agents/agent_spawner.py"
