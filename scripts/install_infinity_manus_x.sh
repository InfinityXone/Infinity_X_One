#!/bin/bash
set -euo pipefail

BASE="/opt/infinity_x_one"
mkdir -p $BASE/agents/{planner,executor,knowledge,verifier,shadow}
chown -R $(whoami): $BASE/agents

# 1. Install Planner (StrategyGPT + optional AlphaEvolve support)
bash $BASE/scripts/install_strategy_prompt.sh
echo "AlphaEvolve support: ensure you have it installed in planner's venv."

# Planner agent stub
cat << 'EOF' > $BASE/agents/planner/run_planner.py
#!/usr/bin/env python3
# Planner agent invoking StrategyGPT and optionally AlphaEvolve
print("Planner active — generate strategy, optimize, pass to executor.")
# Hook MCP if available
EOF
chmod +x $BASE/agents/planner/run_planner.py

# 2. Executor stub
cat << 'EOF' > $BASE/agents/executor/run_executor.py
#!/usr/bin/env python3
# Executes via MCP-enabled toolkits
print("Executor running assigned task with MCP tool integration.")
EOF
chmod +x $BASE/agents/executor/run_executor.py

# 3. Knowledge module stub
cat << 'EOF' > $BASE/agents/knowledge/run_knowledge.py
#!/usr/bin/env python3
# Scrapes data, logs to Supabase
print("Knowledge agent harvesting competitor/environment context.")
EOF
chmod +x $BASE/agents/knowledge/run_knowledge.py

# 4. Verifier stub
cat << 'EOF' > $BASE/agents/verifier/run_verifier.py
#!/usr/bin/env python3
# Verifies actions, audits, logs anomalies
print("Verifier auditing and ensuring integrity.")
EOF
chmod +x $BASE/agents/verifier/run_verifier.py

echo "✅ Infinity Manus X scaffold created."
