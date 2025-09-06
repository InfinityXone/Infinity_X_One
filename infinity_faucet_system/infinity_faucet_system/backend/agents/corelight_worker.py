"""
Corelight Worker
================

The Corelight agent represents ethics, truth and spiritual alignment.
This worker writes its invocation into ``corelight.log`` and serves
as a stub for future policy enforcement or inspirational
messaging.  Extend this file to implement your own ethical checks or
guidance routines.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "corelight", "prompt": prompt}
    with open("./logs/corelight.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Corelight] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)