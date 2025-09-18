#!/bin/bash
echo "🚀 Starting Infinity X One Bootstrap Setup"

# 1. Create core folders
echo "📁 Creating /opt/infinity_x_one folders..."
sudo mkdir -p /opt/infinity_x_one/{agents,logs,k8s,scripts,env,supabase,.github/workflows}
sudo mkdir -p /mnt/data/{k8s,agents,seeds,supabase}

# 2. Copy from /mnt/data into /opt/infinity_x_one
echo "📦 Syncing dropped files from /mnt/data..."
sudo cp -r /mnt/data/k8s/* /opt/infinity_x_one/k8s/
sudo cp -r /mnt/data/agents/* /opt/infinity_x_one/agents/
sudo cp -r /mnt/data/supabase/* /opt/infinity_x_one/supabase/
sudo cp -r /mnt/data/.github/* /opt/infinity_x_one/.github/

# 3. Install dependencies
echo "🔧 Installing Python + curl dependencies..."
sudo apt update && sudo apt install -y python3 python3-pip curl git
pip3 install requests

# 4. Create Infinity Agent One systemd service
echo "🧠 Registering infinity_agent_one systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/infinity_agent_one.service
[Unit]
Description=Infinity Agent One - Watchdog + API Headless
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/infinity_x_one/agents/infinity_agent_one.py
Restart=always
RestartSec=10
User=$USER
EnvironmentFile=/opt/infinity_x_one/env/master.env
StandardOutput=append:/opt/infinity_x_one/logs/agent_one.log
StandardError=append:/opt/infinity_x_one/logs/agent_one.err

[Install]
WantedBy=multi-user.target
EOF

# 5. Enable and start service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable infinity_agent_one
sudo systemctl start infinity_agent_one

# 6. Optional: deploy Supabase GPT Hook
echo "🛰 Preparing Supabase Function (gpt-hook)..."
cd /opt/infinity_x_one/supabase/functions/gpt-hook
supabase functions deploy gpt-hook || echo "⚠️ Supabase CLI not available. Deploy manually."

# 7. GitHub repo ready
echo "🔗 Initializing Git repo..."
cd /opt/infinity_x_one
git init
git add .
git commit -m "🧬 Initial Infinity X One system drop"
# OPTIONAL: git remote add origin <YOUR_REPO_URL>
# git push -u origin main

# 8. Confirm Infinity Agent One is running
echo "✅ System Initialized. Checking agent status..."
sudo systemctl status infinity_agent_one

echo "🎉 Infinity X One Bootstrap Complete — Ready for Drop."
