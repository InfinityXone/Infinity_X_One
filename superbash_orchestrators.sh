#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity X One] Superbash Orchestrator Setup"
LOG_DIR="/opt/infinity_x_one/logs"
ENV_FILE="/opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt"
mkdir -p "$LOG_DIR"

# === Agent Mode Master ===
cat <<EOF | sudo tee /etc/systemd/system/agent_mode_master.service
[Unit]
Description=Infinity X One • Agent Mode Master Orchestrator
After=network.target

[Service]
ExecStart=/opt/infinity_x_one/agent_mode_master.sh
WorkingDirectory=/opt/infinity_x_one
Restart=always
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/agent_mode_master.log
StandardError=append:$LOG_DIR/agent_mode_master.err

[Install]
WantedBy=multi-user.target
EOF

# === Hive Orchestrator ===
cat <<EOF | sudo tee /etc/systemd/system/hive_orchestrator.service
[Unit]
Description=Infinity X One • Hive Orchestrator
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/infinity_x_one/hive_orchestrator.py
WorkingDirectory=/opt/infinity_x_one
Restart=always
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/hive_orchestrator.log
StandardError=append:$LOG_DIR/hive_orchestrator.err

[Install]
WantedBy=multi-user.target
EOF

# === Agent Orchestrator ===
cat <<EOF | sudo tee /etc/systemd/system/agent_orchestrator.service
[Unit]
Description=Infinity X One • Agent Orchestrator
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/infinity_x_one/agent_orchestrator.py
WorkingDirectory=/opt/infinity_x_one
Restart=always
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/agent_orchestrator.log
StandardError=append:$LOG_DIR/agent_orchestrator.err

[Install]
WantedBy=multi-user.target
EOF

# === Superbash Master ===
cat <<EOF | sudo tee /etc/systemd/system/superbash_master.service
[Unit]
Description=Infinity X One • Superbash Master
After=network.target

[Service]
ExecStart=/opt/infinity_x_one/superbash_master.sh
WorkingDirectory=/opt/infinity_x_one
Restart=always
User=infinity-x-one
EnvironmentFile=$ENV_FILE
StandardOutput=append:$LOG_DIR/superbash_master.log
StandardError=append:$LOG_DIR/superbash_master.err

[Install]
WantedBy=multi-user.target
EOF

# Reload + enable + start all
echo "🔄 Reloading systemd and enabling services..."
sudo systemctl daemon-reexec
sudo systemctl enable agent_mode_master.service hive_orchestrator.service agent_orchestrator.service superbash_master.service
sudo systemctl restart agent_mode_master.service hive_orchestrator.service agent_orchestrator.service superbash_master.service

echo "✅ All orchestrators deployed and running under systemd"
