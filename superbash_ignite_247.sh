#!/bin/bash
set -euo pipefail

echo "🧬 [Infinity AI Swarm] 24/7 Ignite Protocol"

# Ensure logs directory
mkdir -p /opt/infinity_x_one/logs

# Function to generate systemd units
make_service () {
  local name=$1
  local exec=$2
  local logname=$3
  cat <<EOF | sudo tee /etc/systemd/system/${name}.service
[Unit]
Description=Infinity AI Swarm • ${name}
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/infinity_x_one/Infinity_AI_Swarm/backend/agents/${exec}
WorkingDirectory=/opt/infinity_x_one/Infinity_AI_Swarm
Restart=always
RestartSec=15
User=infinity-x-one
EnvironmentFile=/opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt
StandardOutput=append:/opt/infinity_x_one/logs/${logname}.log
StandardError=append:/opt/infinity_x_one/logs/${logname}.err

[Install]
WantedBy=multi-user.target
EOF
}

# Core agents
make_service "atlas" "atlas_worker.py" "atlas"
make_service "keyharvester" "api_key_harvester.py" "keyharvester"
make_service "scraperx" "scraperx_worker.py" "scraperx"

# Main faucet swarm agents
make_service "faucet_infinity" "infinity_worker.py" "faucet_infinity"
make_service "faucet_codex" "codex_worker.py" "faucet_codex"
make_service "faucet_aria" "aria_worker.py" "faucet_aria"
make_service "faucet_echo" "echo_worker.py" "faucet_echo"
make_service "faucet_guardian" "guardian_worker.py" "faucet_guardian"
make_service "faucet_pickybot" "pickybot_worker.py" "faucet_pickybot"
make_service "faucet_finsynapse" "finsynapse_worker.py" "faucet_finsynapse"
make_service "faucet_corelight" "corelight_worker.py" "faucet_corelight"

# Swarm deploy (keeps repo synced + redeployed hourly)
cat <<'EOF' | sudo tee /etc/systemd/system/swarm_deploy.service
[Unit]
Description=Infinity AI Swarm • Auto Deploy
After=network.target

[Service]
ExecStart=/opt/infinity_x_one/superbash_swarm_deploy.sh
WorkingDirectory=/opt/infinity_x_one/Infinity_AI_Swarm
Restart=always
RestartSec=3600
User=infinity-x-one
EnvironmentFile=/opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt
StandardOutput=append:/opt/infinity_x_one/logs/swarm_deploy.log
StandardError=append:/opt/infinity_x_one/logs/swarm_deploy.err

[Install]
WantedBy=multi-user.target
EOF

# Reload + enable everything
sudo systemctl daemon-reexec
sudo systemctl enable atlas.service keyharvester.service scraperx.service \
  faucet_infinity.service faucet_codex.service faucet_aria.service faucet_echo.service \
  faucet_guardian.service faucet_pickybot.service faucet_finsynapse.service faucet_corelight.service \
  swarm_deploy.service

sudo systemctl restart atlas.service keyharvester.service scraperx.service \
  faucet_infinity.service faucet_codex.service faucet_aria.service faucet_echo.service \
  faucet_guardian.service faucet_pickybot.service faucet_finsynapse.service faucet_corelight.service \
  swarm_deploy.service

echo "✅ Infinity AI Swarm is now ignited 24/7. All agents are in eternal loops."

