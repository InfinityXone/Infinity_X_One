#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity X One] Immortal Orchestrator Installer"

LOG_DIR="/opt/infinity_x_one/logs"
ENV_FILE="/opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt"
mkdir -p "$LOG_DIR"

create_loop_wrapper () {
  local name=$1
  local target=$2
  local wrapper="/opt/infinity_x_one/${name}_loop.sh"

  echo "🔧 Creating loop wrapper for $name..."
  cat <<EOF > $wrapper
#!/bin/bash
while true; do
  echo "🚀 Starting $name..."
  $target
  echo "🔄 [$name] Restarting in 30s..."
  sleep 30
done
EOF
  chmod +x $wrapper
}

create_service () {
  local name=$1
  local exec=$2
  local log_name=$3

  echo "🔧 Creating systemd service for $name..."
  cat <<EOF | sudo tee /etc/systemd/system/${name}.service
[Unit]
Description=Infinity X One • ${name^} Orchestrator
After=network.target

[Service]
ExecStart=$exec
WorkingDirectory=/opt/infinity_x_one
Restart=always
RestartSec=5
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/${log_name}.log
StandardError=append:$LOG_DIR/${log_name}.err

[Install]
WantedBy=multi-user.target
EOF
}

# === Agent Mode Master ===
create_loop_wrapper "agent_mode_master" "/opt/infinity_x_one/agent_mode_master.sh"
create_service "agent_mode_master" "/opt/infinity_x_one/agent_mode_master_loop.sh" "agent_mode_master"

# === Hive Orchestrator ===
create_loop_wrapper "hive_orchestrator" "/usr/bin/python3 /opt/infinity_x_one/hive_orchestrator.py"
create_service "hive_orchestrator" "/opt/infinity_x_one/hive_orchestrator_loop.sh" "hive_orchestrator"

# === Agent Orchestrator ===
create_loop_wrapper "agent_orchestrator" "/usr/bin/python3 /opt/infinity_x_one/agent_orchestrator.py"
create_service "agent_orchestrator" "/opt/infinity_x_one/agent_orchestrator_loop.sh" "agent_orchestrator"

# === Superbash Master ===
create_loop_wrapper "superbash_master" "/opt/infinity_x_one/superbash_master.sh"
create_service "superbash_master" "/opt/infinity_x_one/superbash_master_loop.sh" "superbash_master"

# Reload + enable + start all
echo "🔄 Reloading systemd and enabling orchestrator services..."
sudo systemctl daemon-reexec
sudo systemctl enable agent_mode_master.service hive_orchestrator.service agent_orchestrator.service superbash_master.service
sudo systemctl restart agent_mode_master.service hive_orchestrator.service agent_orchestrator.service superbash_master.service

echo "✅ All orchestrators are now immortal and running under systemd."
