"""
PromptWriter Worker
===================

Acts as the CEO / Meta Architect of the Infinity X One swarm.  This
worker interprets high‑level directives and orchestrates the other
agents accordingly.  In this simplified version it writes the
directive into ``promptwriter.log`` for audit purposes.  Extend this
script to push complex instructions into Supabase or your orchestration
engine.
"""

import json
import os
import sys
from datetime import datetime

def main(prompt: str) -> None:
    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {"timestamp": ts, "agent": "promptwriter", "prompt": prompt}
    with open("./logs/promptwriter.log", "a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")
    print(f"[PromptWriter] Executed with prompt: {prompt}")


if __name__ == "__main__":
    prompt_arg = sys.argv[1] if len(sys.argv) > 1 else ""
    main(prompt_arg)