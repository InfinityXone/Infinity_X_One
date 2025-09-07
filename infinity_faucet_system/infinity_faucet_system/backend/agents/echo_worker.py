"""
Echo Worker
===========

The Echo agent is your logger and communicator.  It echoes directives
back to your logs and could relay messages between agents.  This
simple implementation appends a log entry to ``echo.log`` and prints
the prompt.  Extend it to perform richer logging or persistent chat
history storage.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "echo", "prompt": prompt}
    with open("./logs/echo.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Echo] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)