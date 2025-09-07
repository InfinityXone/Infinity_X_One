"""
Atlas Worker
===========

Responsible for provisioning compute on external providers.  This
implementation writes an entry into ``atlas.log`` indicating that
compute provisioning has been requested.  Extend this script to call
cloud provider APIs (e.g. AWS, GCP, Vast.ai) and register the nodes
into Supabase.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "atlas", "prompt": prompt}
    with open("./logs/atlas.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Atlas] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)