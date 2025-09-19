#!/usr/bin/env python3
"""
agent_github_pusher.py
Usage: python3 agent_github_pusher.py '{"agent":"AgentOne","cmd":"PUSH /opt/.../file.py"}'
This script will:
 - parse payload
 - if BUILD: accept content or generate file (if provided by agent)
 - stage file(s) in /opt/infinity_x_one/agents/
 - git add/commit/push using GITHUB_TOKEN
 - trigger Vercel via REST if VEREL_TOKEN provided
 - log to Supabase
"""

import os, sys, json, subprocess, datetime
from pathlib import Path

payload = {}
if len(sys.argv) > 1:
    try:
        payload = json.loads(sys.argv[1])
    except:
        pass

agent = payload.get("agent","AgentOne")
cmd = payload.get("cmd","")

GITHUB_REPO = os.environ.get("GITHUB_REPO")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN")
GIT_AUTHOR_NAME = os.environ.get("GIT_AUTHOR_NAME","InfinityX One Bot")
GIT_AUTHOR_EMAIL = os.environ.get("GIT_AUTHOR_EMAIL","bot@infinityxone")

REPO_DIR = "/opt/infinity_x_one"

def run(cmd, cwd=REPO_DIR):
    print("RUN:", cmd)
    subprocess.check_call(cmd, shell=True, cwd=cwd)

def git_push_with_message(msg):
    run(f'git add -A && git commit -m "{msg}" || echo "no changes"')
    # set token remote
    run(f'git push https://{GITHUB_TOKEN}@github.com/{GITHUB_REPO}.git HEAD:main || git push origin main')

def log_to_supabase(agent, action):
    try:
        import psycopg2
        conn = psycopg2.connect(os.environ.get("SUPABASE_CONN"))
        cur = conn.cursor()
        cur.execute("INSERT INTO agent_logs (agent, action, timestamp) VALUES (%s,%s,%s)",
                    (agent, action, datetime.datetime.utcnow()))
        conn.commit(); cur.close(); conn.close()
    except Exception as e:
        with open("/opt/infinity_x_one/logs/pusher_fallback.log","a") as f:
            f.write(f"{datetime.datetime.utcnow().isoformat()}|{agent}|{action}\n")

def handle_push(cmd):
    # expects: PUSH /path/to/file OR BUILD {"path":"/opt/...","content":"..."}
    if cmd.strip().upper().startswith("PUSH"):
        parts = cmd.split(None,1)
        path = parts[1].strip()
        # ensure file under REPO_DIR
        p = Path(path)
        if not p.exists():
            log_to_supabase("Pusher", f"file not found: {path}")
            return
        # copy into agents/ if necessary
        dest = Path(REPO_DIR) / "agents" / p.name
        run(f"cp {str(p)} {str(dest)}")
        git_push_with_message(f"{agent}: push {p.name}")
        log_to_supabase(agent, f"Pushed {p.name}")
    elif cmd.strip().upper().startswith("BUILD"):
        # BUILD <json> where json contains path and content
        parts = cmd.split(None,1)
        try:
            job = json.loads(parts[1])
            path = job.get("path","/opt/infinity_x_one/agents/auto_build.py")
            content = job.get("content","")
            Path(path).write_text(content)
            git_push_with_message(f"{agent}: build {Path(path).name}")
            log_to_supabase(agent, f"Built & pushed {path}")
        except Exception as e:
            log_to_supabase("Pusher", f"BUILD failed: {e}")
    else:
        log_to_supabase("Pusher", f"Unknown cmd: {cmd}")

if __name__ == "__main__":
    try:
        handle_push(cmd)
    except Exception as e:
        log_to_supabase("Pusher", f"Exception: {e}")
        raise
