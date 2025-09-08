#!/bin/bash

echo "🔧 Fixing vercel.json and pushing clean config to GitHub..."

# Define the path
FRONTEND_PATH="/opt/infinity_x_one/frontend"
VERCEL_JSON="$FRONTEND_PATH/vercel.json"

# Backup existing config
cp "$VERCEL_JSON" "$FRONTEND_PATH/vercel_backup_$(date +%s).json"

# Overwrite with minimal, clean config
cat <<EOF > "$VERCEL_JSON"
{
  "framework": "nextjs",
  "rewrites": [{ "source": "/(.*)", "destination": "/" }]
}
EOF

echo "✅ Updated vercel.json with minimal config."

# Git add/commit/push the config
cd "$FRONTEND_PATH" || exit
git add vercel.json
git commit -m "🧹 Clean vercel.json for modern deployment (no deprecated fields)"
git push origin main

# Trigger deploy to Vercel (in background)
echo "🚀 Deploying to Vercel in background..."
vercel --prod --yes > /opt/infinity_x_one/records/vercel_deploy.log 2>&1 &

echo "✅ Deployment triggered. Monitor with:"
echo "   tail -f /opt/infinity_x_one/records/vercel_deploy.log"
