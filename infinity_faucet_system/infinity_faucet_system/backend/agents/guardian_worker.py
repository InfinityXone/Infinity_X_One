"""
Guardian Worker
===============

This script is invoked by the gateway whenever a directive is sent to
the ``guardian`` agent.  In this simplified example it logs the
received prompt and writes a heartbeat entry to ``./logs/guardian.log``.
In a production deployment this worker would enforce security
policies, perform integrity checks and potentially halt unsafe
operations.
"""

import json
import os
import sys
from datetime import datetime


def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "guardian", "prompt": prompt}
    with open("./logs/guardian.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Guardian] Executed with prompt: {prompt}")


if __name__ == "__main__":
    # Accept prompt as a single command‑line argument (quoted).
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)