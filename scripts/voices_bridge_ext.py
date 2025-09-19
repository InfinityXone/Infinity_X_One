#!/usr/bin/env python3
"""
voices_bridge_ext.py
Unified chat bridge: listens for chat/webhook messages, keeps agent personas permanently 'in chat',
parses @AgentName commands and routes to agent workers. Supports Groq -> OpenAI fallback,
loads a unified brain file, logs to Supabase, and can hand off code to the GitHub pusher.

Drop into /mnt/data/scripts/, chmod +x, create systemd unit to run always.
"""

import os, time, json, threading, datetime, queue, subprocess
from pathlib import Path

# Optional libs: requests, psycopg2, pygithub, flask, openai (install in venv)
try:
    import requests
except Exception:
    requests = None

# ----------------- CONFIG -----------------
SUPABASE_CONN = os.environ.get("SUPABASE_CONN")
GROQ_KEY = os.environ.get("GROQ_API_KEY")
OPENAI_KEY = os.environ.get("OPENAI_API_KEY")
UNIFIED_BRAIN = os.environ.get("UNIFIED_BRAIN_PATH", "/opt/infinity_x_one/prompts/unified_brain.txt")
LOG_PATH = "/opt/infinity_x_one/logs/voices_bridge_ext.log"
CMD_FIFO = "/opt/infinity_x_one/voices_cmd_fifo"   # named pipe fallback if needed
WEBHOOK_PORT = int(os.environ.get("VOICES_BRIDGE_PORT", "8082"))
GITHUB_PUSH_ENDPOINT = "/opt/infinity_x_one/scripts/agent_github_pusher.py"  # handoff

# Permanent agent list & personalities (can be overridden by DB)
AGENTS = {
    "AgentOne": {"persona":"Infinity Agent One","role":"builder,financial,deploy"},
    "Guardian": {"persona":"Guardian","role":"security,ethics"},
    "PickyBot": {"persona":"PickyBot","role":"auditor,optimizer"},
    "Codex": {"persona":"Codex","role":"technical,infra"},
    "FinSynapse": {"persona":"FinSynapse","role":"finance,sniper"},
    "Atlas": {"persona":"Atlas","role":"compute,provision"},
    "Echo": {"persona":"Echo","role":"resonance,ux"},
    "Aria": {"persona":"Aria","role":"alignment,spirit"}
}

# in-memory state
active_agents = {k: True for k in AGENTS.keys()}   # permanent presence
command_q = queue.Queue()

# ----------------- Helpers -----------------
def log(s):
    with open(LOG_PATH, "a") as f:
        f.write(f"[{datetime.datetime.utcnow().isoformat()}] {s}\n")
    print(s)

def call_llm(prompt, system=None, max_tokens=512):
    """
    Try Groq, fallback to OpenAI.
    Implement your Groq API call here if available; otherwise call OpenAI.
    """
    # Groq primary (pseudo) - replace with real SDK call
    if GROQ_KEY:
        try:
            # Example placeholder - adapt to your Groq client
            resp = requests.post("https://api.groq.ai/v1/generate",
                                 headers={"Authorization": f"Bearer {GROQ_KEY}"},
                                 json={"prompt": prompt, "max_tokens": max_tokens})
            if resp.ok:
                return resp.json().get("text","")
        except Exception as e:
            log(f"Groq error: {e}")

    # Fallback to OpenAI
    if OPENAI_KEY:
        try:
            import openai
            openai.api_key = OPENAI_KEY
            res = openai.ChatCompletion.create(
                model="gpt-4o-mini", messages=[{"role":"system","content": system or "You are an agent."},
                                               {"role":"user","content": prompt}], max_tokens=max_tokens)
            return res["choices"][0]["message"]["content"].strip()
        except Exception as e:
            log(f"OpenAI error: {e}")
    return "⚠️ No LLM response available."

def log_to_supabase(agent, action):
    # Minimal log insertion via psql CLI as fallback if psycopg2 unavailable
    try:
        import psycopg2
        conn = psycopg2.connect(SUPABASE_CONN)
        cur = conn.cursor()
        cur.execute("INSERT INTO agent_logs (agent, action, timestamp) VALUES (%s,%s,%s)",
                    (agent, action, datetime.datetime.utcnow()))
        conn.commit(); cur.close(); conn.close()
    except Exception as e:
        log(f"Supabase log failed: {e}")
        # fallback: append to local log
        with open("/opt/infinity_x_one/logs/agent_logs_fallback.log","a") as f:
            f.write(f"{datetime.datetime.utcnow().isoformat()} | {agent} | {action}\n")

# ----------------- Worker Routing -----------------
def handle_command(raw_cmd):
    """
    Expected formats:
      @AgentOne do X
      @Atlas provision 5 nodes
      @AgentOne:BUILD <json payload>
      @AgentOne PUSH /path/to/file.py  (hands file path to pusher)
      @dismiss AgentOne
    """
    raw = raw_cmd.strip()
    if not raw.startswith("@"):
        return
    parts = raw[1:].split(None,1)
    if not parts:
        return
    agent = parts[0].strip()
    remainder = parts[1] if len(parts)>1 else ""
    agent_key = agent.replace(":","")

    if agent_key.lower() == "dismiss":
        # dismiss names after dismiss call
        to_dismiss = remainder.split()
        for a in to_dismiss:
            active_agents[a] = False
            log_to_supabase("Bridge", f"Dismissed {a}")
        return

    if agent_key not in AGENTS:
        log_to_supabase("Bridge", f"Unknown agent: {agent_key}")
        return

    # process the command
    log_to_supabase(agent_key, remainder or "(heartbeat)")
    # if the command starts with PUSH or BUILD -> handoff to pusher
    if remainder.strip().upper().startswith("PUSH") or remainder.strip().upper().startswith("BUILD"):
        # PUSH /path => call agent_github_pusher with args
        payload = {"agent":agent_key, "cmd": remainder}
        # use subprocess to call the pusher script
        try:
            subprocess.run(["python3", GITHUB_PUSH_ENDPOINT, json.dumps(payload)], check=True)
            log(f"{agent_key} handed off to pusher: {remainder[:120]}")
        except Exception as e:
            log(f"Failed to call pusher: {e}")
        return

    # handle simple text command — ask LLM for response and/or action
    system_prompt = f"You are {AGENTS[agent_key]['persona']} acting as {AGENTS[agent_key]['role']} for Infinity X One."
    # Optionally incorporate unified brain file as extra context
    brain = ""
    if Path(UNIFIED_BRAIN).exists():
        try:
            brain = Path(UNIFIED_BRAIN).read_text()[:3000]
        except:
            brain = ""
    prompt = f"{brain}\n\nCommand: {remainder}\n\nRespond with a concise agent response; if action needed, provide a structured ACTION JSON."
    out = call_llm(prompt, system_prompt)
    # If the LLM replies with an action block, parse it (naive)
    log_to_supabase(agent_key, out)
    log(f"[{agent_key}] {out}")

# ----------------- Chat ingestion: two modes -----------------
# 1) Webhook mode (preferred): a Flask endpoint receives chat messages (POST JSON {'text': '...'})
# 2) FIFO file mode: read a named pipe or file that your front-end writes to

def webhook_server():
    from flask import Flask, request, jsonify
    app = Flask("voices_bridge_ext")

    @app.route("/event", methods=["POST"])
    def event():
        data = request.get_json(force=True)
        text = data.get("text","")
        # Accept a direct @AgentName invocation
        if text.startswith("@"):
            command_q.put(text)
        else:
            # If no @, treat as general input: pass to PromptWriter or broadcast
            pass
        return jsonify({"ok":True})

    log(f"Starting webhook server on port {WEBHOOK_PORT}")
    app.run(host="0.0.0.0", port=WEBHOOK_PORT)

def fifo_reader_loop():
    # create fifo if missing
    try:
        if not os.path.exists(CMD_FIFO):
            os.mkfifo(CMD_FIFO)
    except Exception as e:
        log(f"fifo create error: {e}")

    log("Starting FIFO reader loop")
    while True:
        try:
            with open(CMD_FIFO, "r") as fh:
                for line in fh:
                    line=line.strip()
                    if not line: continue
                    command_q.put(line)
        except Exception as e:
            log(f"fifo read error: {e}")
            time.sleep(2)

# ----------------- Main loop ----------
def command_processor():
    log("Command processor started")
    while True:
        try:
            cmd = command_q.get(timeout=1)
        except queue.Empty:
            time.sleep(0.2); continue
        try:
            handle_command(cmd)
        except Exception as e:
            log(f"Error handling command {cmd}: {e}")

if __name__ == "__main__":
    # spawn webhook thread if Flask available, else_fifo
    if requests is not None:
        t = threading.Thread(target=webhook_server, daemon=True)
        t.start()
    else:
        t = threading.Thread(target=fifo_reader_loop, daemon=True)
        t.start()

    proc = threading.Thread(target=command_processor, daemon=True)
    proc.start()

    # keep alive
    while True:
        time.sleep(60)
