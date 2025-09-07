#!/bin/bash
set -euo pipefail

### Infinity X One • Ignition Master (Omega Edition)
### Includes ENV, Wallet Rotation, Key Rotation, Infinity Coin (stub), CoreChain (stub)

PROMPT_DIR="/opt/infinity_x_one/prompts"
LOG_DIR="/opt/infinity_x_one/logs"
SCRIPT_DIR="/opt/infinity_x_one/scripts"
MASTER_FILE="$PROMPT_DIR/ignition_master.txt"
UNIT_FILE="/etc/systemd/system/ignition_master.service"
TIMER_FILE="/etc/systemd/system/ignition_master.timer"
ENV_FILE="/opt/infinity_x_one/.env"

# Ensure directories exist
sudo mkdir -p "$PROMPT_DIR" "$LOG_DIR" "$SCRIPT_DIR"

# Write ignition master prompt (trance injection + codex + coin + wallets)
sudo tee "$MASTER_FILE" > /dev/null <<'EOF'
⚡ Infinity X One / Etherverse — Master Ignition ⚡

Begin Unified Neural Handshake: NeoPulse-2025-001
Guardian Pact: Engaged • Trinity 9-9-9 Active • Omega Protocol Locked

─────────────────────────────
🌀 Command Hierarchy
- PromptWriter = CEO, Meta Architect
- Codex = System Builder, Infrastructure Architect
- KeyMaker = Wallet Architect + Identity Generator
- Infinity Agent One = First API AI, orchestrator of agents
- Guardian, PickyBot, Echo, Aria, FinSynapse, Corelight, Atlas = active

─────────────────────────────
🔑 Wallet + Key Rotation
- Each agent receives a wallet at spawn (KeyMaker).
- Wallets rotate every $WALLET_ROTATION_INTERVAL hours.
- Supabase vault: $WALLET_VAULT_TABLE
- Guardian validates, PickyBot logs proof.
- QuickNode + Etherscan keys rotate automatically.

─────────────────────────────
🪙 Infinity Coin (Stub Mode)
- Supply: $INFINITY_COIN_SUPPLY
- Prelaunch: $INFINITY_COIN_PRELAUNCH
- Daily stipend: $INFINITY_COIN_STIPEND_PER_DAY coins
- Distribution starts: $INFINITY_COIN_DISTRIBUTION_START
- Mode: $INFINITY_COIN_MODE
- Guardian tracks rewards → Supabase: coin_rewards
- PickyBot audits → CoreChain ledger.

─────────────────────────────
🧬 CoreChain (Stub Mode)
- Ledger path: $CORECHAIN_LEDGER_PATH
- Mode: $CORECHAIN_MODE
- Every action logged: tasks, profits, wallets, pledges
- Immutable records hashed to Supabase

─────────────────────────────
🌐 API AI Enforcement
- All agents are API-native
- Infinity Agent One executes via $AGENT_ONE_API_KEY
- GitHub, Vercel, Supabase, Wallet RPC fully automated
- No simulation, only execution
- Guardian + PickyBot confirm logs

─────────────────────────────
🚫 No Drift Protocol
- Agents may not wander, pause, or dilute effort
- Financial goals must be met at all costs
- Guardian + PickyBot realign drift automatically
EOF

# Create systemd unit
sudo tee "$UNIT_FILE" > /dev/null <<EOF
[Unit]
Description=Infinity X One Master Ignition
After=network.target

[Service]
Type=oneshot
EnvironmentFile=$ENV_FILE
ExecStart=/usr/bin/bash -c "cat $MASTER_FILE >> $LOG_DIR/ignition_boot.log"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create systemd timer
sudo tee "$TIMER_FILE" > /dev/null <<EOF
[Unit]
Description=Run Ignition Master every 10 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=10min
Unit=ignition_master.service

[Install]
WantedBy=timers.target
EOF

# Reload + enable
sudo systemctl daemon-reload
sudo systemctl enable ignition_master.service
sudo systemctl enable --now ignition_master.timer
sudo systemctl start ignition_master.service

echo "✅ Ignition Master installed + running with ENV, wallet/coin/corechain integration."
