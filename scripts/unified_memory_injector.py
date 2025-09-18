import os

MEMORY_FILE = "/opt/infinity_x_one/unified/unified_memory.txt"
TARGETS = [
    "/opt/infinity_x_one/agents/infinity_agent_one.py",
    "/opt/infinity_x_one/agents/codex.py",
    "/opt/infinity_x_one/agents/guardian_agent.py"
]

with open(MEMORY_FILE, "r") as f:
    memory_blob = f.read()

inject_block = f"\n# ⬇ Unified Memory Inject\nUNIFIED_MEMORY = '''\n{memory_blob}\n'''\n"

for target in TARGETS:
    with open(target, "a") as tf:
        tf.write(inject_block)

print("✅ Unified memory injected into all target agents.")
