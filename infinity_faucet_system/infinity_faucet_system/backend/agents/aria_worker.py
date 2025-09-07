"""
Aria Worker
===========

Aria embodies the artistic and spiritual side of the swarm.  This
worker might be responsible for generating uplifting prompts,
maintaining ethical tone or interfacing with the Corelight agent.  In
this minimal version it simply logs its invocation to ``aria.log``.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "aria", "prompt": prompt}
    with open("./logs/aria.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Aria] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)