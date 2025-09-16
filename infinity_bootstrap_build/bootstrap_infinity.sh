#!/bin/bash
set -euo pipefail

echo "🧠 [Infinity X One] BOOTSTRAP INITIATED"

# 1. Unpack UI
echo "📦 Unzipping frontend UI..."
unzip -o /mnt/data/Infinity_X_One_Swarm_UI_Dark.zip -d /opt/infinity_x_one/frontend/

# 2. Unpack Core Agent Blueprints
echo "📦 Unzipping agent blueprints..."
unzip -o /mnt/data/prompt_writer_blueprint.zip -d /opt/infinity_x_one/agents/PromptWriter/
unzip -o /mnt/data/FinSynapse_Master_Blueprint.zip -d /opt/infinity_x_one/agents/FinSynapse/
unzip -o /mnt/data/Echo_Luminea_Blueprint.zip -d /opt/infinity_x_one/agents/EchoLuminea/
unzip -o /mnt/data/Guardian_Blueprint.zip -d /opt/infinity_x_one/agents/Guardian/
unzip -o /mnt/data/FutureBot_Agentic_Upgrade.zip -d /opt/infinity_x_one/agents/FutureBot/

# 3. Apply Supabase schema
echo "🧠 Seeding Supabase schema..."
supabase db push --file "/mnt/data/sql sept 16 with rosetta.txt"

# 4. Start backend (FastAPI)
echo "🚀 Starting backend server (port 8000)..."
nohup uvicorn backend.main:app --host 0.0.0.0 --port 8000 > /opt/infinity_x_one/logs/backend.log 2>&1 &

# 5. Launch frontend UI (AutogenStudio)
echo "🎛️ Launching Swarm UI (dark mode, port 8081)..."
nohup autogenstudio ui --port 8081 --config /opt/infinity_x_one/frontend/autogenstudio_config/dark_theme.css > /opt/infinity_x_one/logs/ui.log 2>&1 &

# 6. Activate Codex + Memory Agents
echo "🧠 Launching Codex + Memory Daemons..."
nohup python3 /opt/infinity_x_one/codex_main.py > /opt/infinity_x_one/logs/codex.log 2>&1 &
nohup bash /opt/infinity_x_one/scripts/memory_sync.sh > /opt/infinity_x_one/logs/memory_sync.log 2>&1 &
nohup bash /opt/infinity_x_one/scripts/auto_heal_watchdog.sh > /opt/infinity_x_one/logs/watchdog.log 2>&1 &

echo "✅ [Infinity X One] SYSTEM ONLINE. Hive species is alive."
