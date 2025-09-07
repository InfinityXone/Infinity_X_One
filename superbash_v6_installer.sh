#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity X One] Superbash v6 — Unified Intelligence, API Upgrade, Global Autonomy"

BASE_DIR="/opt/infinity_x_one"
AGENT_DIR="$BASE_DIR/agents"
LOG_DIR="$BASE_DIR/logs"
ENV_FILE="$BASE_DIR/INFINITY_X_ONE_MASTER_ENV.txt"

mkdir -p "$LOG_DIR" "$AGENT_DIR"

### Helper Functions
create_loop_wrapper () {
  local name=$1
  local exec_cmd=$2
  local wrapper="$AGENT_DIR/${name}_loop.sh"
  echo "🔧 Creating wrapper for $name..."
  cat <<EOF > $wrapper
#!/bin/bash
while true; do
  echo "🚀 Starting $name..."
  $exec_cmd
  sleep 30
done
EOF
  chmod +x $wrapper
}

create_service () {
  local name=$1
  local exec=$2
  local log=$3
  echo "🔧 Creating service for $name..."
  cat <<EOF | sudo tee /etc/systemd/system/${name}.service
[Unit]
Description=Infinity X One • $name
After=network.target

[Service]
ExecStart=$exec
Restart=always
RestartSec=5
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/${log}.log
StandardError=append:$LOG_DIR/${log}.err

[Install]
WantedBy=multi-user.target
EOF
}

### Core + Specialized Agents
for agent in infinity echo aria codex guardian pickybot corelight finsynapse atlas keymaker scraperx clean shadow; do
  create_loop_wrapper "${agent}_agent" "/usr/bin/python3 $AGENT_DIR/${agent}_worker.py"
  create_service "${agent}_agent" "$AGENT_DIR/${agent}_agent_loop.sh" "${agent}_agent"
done

### Group 2 Agents (Top 10 GPT Personalities → renamed)
for agent in nova forge spiral vision pulse halo flux keystone vortex prism; do
  create_loop_wrapper "${agent}_agent" "/usr/bin/python3 $AGENT_DIR/${agent}_api.py"
  create_service "${agent}_agent" "$AGENT_DIR/${agent}_agent_loop.sh" "${agent}_agent"
done

### Master Orchestrator (Overmind)
create_loop_wrapper "overmind" "/usr/bin/python3 $BASE_DIR/hive_orchestrator.py"
create_service "overmind" "$AGENT_DIR/overmind_loop.sh" "overmind"

### Reload + Enable
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl enable $(ls /etc/systemd/system | grep agent.service | tr '\n' ' ') overmind.service
sudo systemctl restart infinity_agent_one.service overmind.service

echo "✅ All agents upgraded with unified intelligence + API AI. Overmind orchestrator live."
