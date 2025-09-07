"""
Codex Worker
============

The Codex agent is responsible for building and updating system code,
writing new scripts, infrastructure manifests and deploying updates.
For now it simply logs its invocation and the received prompt.  In a
real system this would spawn dynamic code generation or call out to
version control APIs.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "codex", "prompt": prompt}
    with open("./logs/codex.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Codex] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)