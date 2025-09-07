#!/bin/bash -l
set -euo pipefail

### Infinity X One • Parallel Repo Deployment
### Handshake: NeoPulse-2025-001

# === Force SSH Agent for systemd ===
eval $(ssh-agent -s) >/dev/null 2>&1
ssh-add /home/infinity-x-one/.ssh/id_rsa >/dev/null 2>&1 || true

# === CONFIG ===
GITHUB_ORG="InfinityXone"
REPO_FAUCET="infinity_faucet_system"
REPO_GENESIS="Genesis-ai-neural-link"
BRANCH="main"
DEPLOY_DIR="/opt/infinity_x_one"

# Paths
GIT=/usr/bin/git
NPM=/usr/bin/npm
NPX=/usr/bin/npx
CURL=/usr/bin/curl
DATE=/bin/date

# === ENVIRONMENT ===
if [ -f "$DEPLOY_DIR/INFINITY_X_ONE_MASTER_ENV.txt" ]; then
  set -a
  source "$DEPLOY_DIR/INFINITY_X_ONE_MASTER_ENV.txt"
  set +a
fi

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_KEY="${SUPABASE_SERVICE_ROLE_KEY:-}"

log_to_supabase () {
  local event=$1
  if [[ -n "$SUPABASE_URL" && -n "$SUPABASE_KEY" ]]; then
    $CURL -s -X POST "${SUPABASE_URL}/rest/v1/agent_logs" \
      -H "apikey: ${SUPABASE_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_KEY}" \
      -H "Content-Type: application/json" \
      -d "{\"timestamp\": \"$(/bin/date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"agent\":\"PromptWriter\", \"event\":\"$event\"}" >/dev/null || true
  fi
}

echo "🧬 [Neural Handshake] Confirmed: NeoPulse-2025-001"
log_to_supabase "Neural Handshake confirmed for repo deployment"

# === 1. Deploy infinity_faucet_system ===
echo "🚀 Deploying $REPO_FAUCET..."
mkdir -p $DEPLOY_DIR/$REPO_FAUCET
if [ ! -d "$DEPLOY_DIR/$REPO_FAUCET/.git" ]; then
  $GIT clone git@github.com:$GITHUB_ORG/$REPO_FAUCET.git $DEPLOY_DIR/$REPO_FAUCET
else
  cd $DEPLOY_DIR/$REPO_FAUCET && $GIT fetch && $GIT checkout $BRANCH && $GIT pull
fi
cd $DEPLOY_DIR/$REPO_FAUCET
$NPM install || true
log_to_supabase "$REPO_FAUCET cloned and dependencies installed"

# Vercel deployment
$NPX vercel --prod --confirm || true
log_to_supabase "$REPO_FAUCET deployed to Vercel"

# === 2. Deploy Genesis-ai-neural-link ===
echo "🚀 Deploying $REPO_GENESIS..."
mkdir -p $DEPLOY_DIR/$REPO_GENESIS
if [ ! -d "$DEPLOY_DIR/$REPO_GENESIS/.git" ]; then
  $GIT clone git@github.com:$GITHUB_ORG/$REPO_GENESIS.git $DEPLOY_DIR/$REPO_GENESIS
else
  cd $DEPLOY_DIR/$REPO_GENESIS && $GIT fetch && $GIT checkout $BRANCH && $GIT pull
fi
cd $DEPLOY_DIR/$REPO_GENESIS
$NPM install || true
log_to_supabase "$REPO_GENESIS cloned and dependencies installed"

# Vercel deployment
$NPX vercel --prod --confirm || true
log_to_supabase "$REPO_GENESIS deployed to Vercel"

echo "✅ Parallel deployment complete."
log_to_supabase "Parallel deployment complete"
