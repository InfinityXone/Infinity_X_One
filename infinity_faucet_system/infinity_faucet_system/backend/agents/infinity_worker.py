"""
Infinity Agent Worker
====================

The Infinity agent is the heart of the swarm, handling replication,
claim execution and acting on behalf of the hive to earn crypto via
faucets, drips and airdrops.  This stub logs its invocation.  You can
extend it to implement the actual faucet claim logic, wallet
management and yield farming loops.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "infinity", "prompt": prompt}
    with open("./logs/infinity.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[Infinity] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)