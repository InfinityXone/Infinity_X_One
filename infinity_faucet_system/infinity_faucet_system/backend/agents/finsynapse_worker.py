"""
FinSynapse Worker
=================

This agent coordinates financial operations such as staking, yield
farming and distributing Infinity Coin rewards.  It reads profit
events from Supabase and decides where to allocate capital.  In this
minimal implementation it writes each directive into ``finsynapse.log``.
Extend this script to interact with blockchain contracts and DeFi
protocols.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "finsynapse", "prompt": prompt}
    with open("./logs/finsynapse.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[FinSynapse] Executed with prompt: {prompt}")

if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)