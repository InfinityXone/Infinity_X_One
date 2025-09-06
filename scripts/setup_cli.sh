#!/bin/bash
set -euo pipefail
ENV_FILE="/opt/infinity_x_one/.env"
export $(grep -v '^#' $ENV_FILE | xargs)

sudo apt update -y
sudo apt install -y curl git npm gh rclone

sudo npm install -g vercel supabase

echo "$GITHUB_TOKEN" | gh auth login --with-token
vercel login --token $VERCEL_TOKEN
supabase login $SUPABASE_SERVICE_ROLE_KEY

# rclone check
rclone listremotes || echo "⚠️ Google Drive not configured. Run: rclone config"

# Log health
mkdir -p /opt/infinity_x_one/logs
{
  echo "GitHub:"; gh auth status
  echo "Vercel:"; vercel whoami
  echo "Supabase:"; supabase projects list
} >> /opt/infinity_x_one/logs/cli_healthcheck.log
