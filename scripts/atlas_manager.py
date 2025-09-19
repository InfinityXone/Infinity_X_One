#!/usr/bin/env python3
"""
atlas_manager.py
Simple modular Atlas manager skeleton:
 - calls provider APIs to create compute instances
 - deploys the core stack by SSH or provider-provisioned scripts
 - reports heartbeats to Supabase
This is provider-agnostic; implement provider adapters for Vast.ai/RunPod/GCP.
"""

import os, time, json, datetime, subprocess
from pathlib import Path

LOG = "/opt/infinity_x_one/logs/atlas.log"
PROVIDERS = {
    "vast": {"api_key": os.environ.get("ATLAS_VAST_KEY")},
    "runpod": {"api_key": os.environ.get("ATLAS_RUNPOD_KEY")},
    # extend adapters here
}

def log(s):
    with open(LOG,"a") as f:
        f.write(f"[{datetime.datetime.utcnow().isoformat()}] {s}\n")
    print(s)

def provision_vast(nodes=1):
    # Placeholder: use Vast.ai API to provision nodes - replace with real calls
    log(f"Provision request to Vast.ai for {nodes} nodes (placeholder).")
    # Return fake node info
    return [{"id":"vast-123","ssh":"user@1.2.3.4"}]

def deploy_stack_to_node(node):
    # Example: SSH and run bootstrap to pull repo & enable services
    ssh = node.get("ssh")
    if not ssh: return False
    log(f"Deploying stack to {ssh} (placeholder).")
    # Example: run remote bootstrap script if SSH key auth exists
    # subprocess.run(["ssh", ssh, "bash -s"], input=open("bootstrap.sh","rb").read())
    return True

def heartbeat():
    # report to supabase (best-effort)
    try:
        import psycopg2
        conn = psycopg2.connect(os.environ.get("SUPABASE_CONN"))
        cur = conn.cursor()
        cur.execute("INSERT INTO agent_logs (agent, action, timestamp) VALUES (%s,%s,%s)",
                    ("Atlas","heartbeat",""))
        conn.commit(); cur.close(); conn.close()
    except Exception as e:
        log(f"heartbeat failed: {e}")

if __name__ == "__main__":
    # simple loop: listen for commands via file
    cmd_file = "/opt/infinity_x_one/atlas_cmd.json"
    while True:
        if Path(cmd_file).exists():
            try:
                job = json.loads(Path(cmd_file).read_text())
                if job.get("action")=="provision":
                    provider = job.get("provider","vast")
                    nodes = int(job.get("nodes",1))
                    if provider=="vast":
                        nodes_info = provision_vast(nodes)
                        for n in nodes_info:
                            deploy_stack_to_node(n)
                        log(f"Provisioned {len(nodes_info)} nodes for provider {provider}")
                Path(cmd_file).unlink()
            except Exception as e:
                log(f"atlas error: {e}")
        heartbeat()
        time.sleep(10)
