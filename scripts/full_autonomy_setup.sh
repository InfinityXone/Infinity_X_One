#!/bin/bash
set -euo pipefail

### Infinity X One • Full Autonomy Setup (Omega Mode)

BASE="/opt/infinity_x_one"
LOG_DIR="$BASE/logs"
ENV_FILE="$BASE/.env"
mkdir -p $LOG_DIR

echo "⚡ [Infinity X One] Beginning Full Autonomy Setup..."

# === Load ENV ===
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
  echo "✅ ENV loaded from $ENV_FILE"
else
  echo "❌ Missing ENV file at $ENV_FILE"
  exit 1
fi

# === Install dependencies ===
echo "🔧 Installing dependencies..."
sudo apt update -y
sudo apt install -y curl git npm gh rclone

# Install node CLIs
sudo npm install -g vercel supabase

# === GitHub CLI ===
if [ -n "${GITHUB_TOKEN:-}" ]; then
  echo "$GITHUB_TOKEN" | gh auth login --with-token
else
  echo "⚠️ GITHUB_TOKEN missing in ENV"
fi

# === Vercel CLI ===
if [ -n "${VERCEL_TOKEN:-}" ]; then
  vercel login --token "$VERCEL_TOKEN" || true
else
  echo "⚠️ VERCEL_TOKEN missing in ENV"
fi

# === Supabase CLI ===
if [ -n "${SUPABASE_SERVICE_ROLE_KEY:-}" ]; then
  supabase login "$SUPABASE_SERVICE_ROLE_KEY"
else
  echo "⚠️ SUPABASE_SERVICE_ROLE_KEY missing in ENV"
fi

# === Google Drive (rclone) ===
if [ -n "${GDRIVE_REMOTE:-}" ]; then
  sudo mkdir -p /mnt/gdrive
  rclone mkdir "$GDRIVE_REMOTE":Infinity_Backups || true
  echo "✅ Google Drive ready at /mnt/gdrive"
else
  echo "⚠️ GDRIVE_REMOTE not configured in ENV"
fi

# === Guardian CLI Audit ===
echo "📋 Running Guardian Audit..."
{
  echo "=== Guardian CLI Audit ==="
  date
  echo "GitHub:"
  gh auth status || echo "GitHub CLI not authenticated"
  echo
  echo "Vercel:"
  vercel whoami || echo "Vercel CLI not authenticated"
  echo
  echo "Supabase:"
  supabase projects list || echo "Supabase CLI not authenticated"
  echo
  echo "Google Drive:"
  rclone listremotes || echo "rclone not configured"
} >> "$LOG_DIR/guardian_cli_audit.log"

echo "✅ Full Autonomy Setup complete. Guardian audit log written to $LOG_DIR/guardian_cli_audit.log"
