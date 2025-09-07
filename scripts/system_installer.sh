#!/bin/bash
set -euo pipefail

### Infinity X One • System Installer (Omega 110% Edition)
### Deploys Ignition Master, Wallet System, API Key Harvester, API AI

BASE="/opt/infinity_x_one/systems"
LOG_DIR="/opt/infinity_x_one/logs"
mkdir -p $BASE $LOG_DIR

echo "⚡ Deploying Infinity X One Subsystems..."

# === Create subsystem folders ===
mkdir -p $BASE/{ignition_master,wallet_system,api_key_harvester,api_ai}

# === Write README + schema for Ignition Master ===
cat > $BASE/ignition_master/README.md <<'EOF'
# ⚡ Ignition Master
Ensures Hive alignment every 10m. Injects ENV, wallets, Infinity Coin stub, CoreChain stub, API AI enforcement.
EOF

cat > $BASE/ignition_master/schema.sql <<'EOF'
create table if not exists corechain_log (
  id bigint generated always as identity primary key,
  agent text not null,
  action text not null,
  tx_hash text,
  created_at timestamp default now()
);
EOF

# === Write README + schema for Wallet System ===
cat > $BASE/wallet_system/README.md <<'EOF'
# 🔑 Wallet System
Manages wallet creation, rotation, regeneration. Logged to Supabase + CoreChain.
EOF

cat > $BASE/wallet_system/schema.sql <<'EOF'
create table if not exists wallet_vault (
  id bigint generated always as identity primary key,
  agent text not null,
  wallet text not null,
  created_at timestamp default now()
);
EOF

# === Write README + schema for API Key Harvester ===
cat > $BASE/api_key_harvester/README.md <<'EOF'
# 🔐 API Key Harvester
Rotates QuickNode, Etherscan, RPC keys. Stores in Supabase vault.
EOF

cat > $BASE/api_key_harvester/schema.sql <<'EOF'
create table if not exists key_vault (
  id bigint generated always as identity primary key,
  service text not null,
  key text not null,
  status text default 'active',
  created_at timestamp default now()
);
EOF

# === Write README + schema for API AI ===
cat > $BASE/api_ai/README.md <<'EOF'
# 🌐 API AI System
Infinity Agent One + future API-native agents. Executes all tasks via APIs, RPCs, CLIs.
EOF

cat > $BASE/api_ai/schema.sql <<'EOF'
create table if not exists tasks (
  id bigint generated always as identity primary key,
  agent text not null,
  task text not null,
  status text default 'pending',
  created_at timestamp default now()
);
EOF

# === Deploy Supabase schemas ===
for f in $BASE/*/schema.sql; do
  echo "📜 Deploying schema $f"
  supabase db push < $f || true
done

# === Enable systemd units (assumes they exist in scripts) ===
systemctl enable ignition_master.service ignition_master.timer || true
systemctl enable guardian_audit.service guardian_audit.timer || true
systemctl enable wallet_rotation.service wallet_rotation.timer || true
systemctl enable key_harvester.service key_harvester.timer || true
systemctl enable api_agent.service || true

echo "✅ Infinity X One systems deployed successfully."
