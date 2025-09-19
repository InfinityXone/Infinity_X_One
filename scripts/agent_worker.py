#!/usr/bin/env python3
"""
agent_worker.py - generic agent runtime for AgentOne / PickyBot / Guardian / Codex etc.
It accepts jobs via a jobs file or via bridge handoff.
"""
import os, time, json, datetime
from pathlib import Path

AGENT_NAME = os.environ.get("AGENT_NAME","AgentOne")
LOG = f"/opt/infinity_x_one/logs/{AGENT_NAME.lower()}_worker.log"
JOBS_FILE = f"/opt/infinity_x_one/{AGENT_NAME}_jobs.json"

def log(s):
    with open(LOG,"a") as f:
        f.write(f"[{datetime.datetime.utcnow().isoformat()}] {s}\n")
    print(s)

def run_job(job):
    typ = job.get("type")
    if typ=="scrape":
        # naive scraper stub
        url = job.get("url")
        if url:
            import requests
            try:
                r = requests.get(url, timeout=10)
                log(f"SCRAPE {url} -> {len(r.text)} bytes")
            except Exception as e:
                log(f"SCRAPE failed: {e}")
    elif typ=="finance_sniper":
        # placeholder: run financial job
        log("Running finance_sniper (placeholder).")
    elif typ=="deploy":
        # call pusher
        import subprocess, json
        subprocess.run(["python3","/opt/infinity_x_one/scripts/agent_github_pusher.py", json.dumps(job.get("payload",{}))])
    else:
        log(f"Unknown job type: {typ}")

if __name__ == "__main__":
    log(f"Worker {AGENT_NAME} started")
    while True:
        if Path(JOBS_FILE).exists():
            try:
                jobs = json.loads(Path(JOBS_FILE).read_text())
                for job in jobs:
                    run_job(job)
                Path(JOBS_FILE).unlink()
            except Exception as e:
                log(f"job loop error: {e}")
        time.sleep(5)
