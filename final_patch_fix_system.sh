#!/bin/bash

echo "🧬 Infinity X One — Final Patch Fix Sequence (v3.3.999)"
echo "────────────────────────────────────────────"

### 1. 🔧 Create /scripts/load_env.sh if missing
mkdir -p /opt/infinity_x_one/scripts
cat <<'EOF' > /opt/infinity_x_one/scripts/load_env.sh
#!/bin/bash
ENV_FILE="/opt/infinity_x_one/env/system.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
  echo "✅ ENV loaded from $ENV_FILE"
else
  echo "❌ ENV file not found: $ENV_FILE"
fi
EOF

chmod +x /opt/infinity_x_one/scripts/load_env.sh

### 2. 🔁 Fix persistent-sync.service
cat <<'EOF' > /etc/systemd/system/persistent-sync.service
[Unit]
Description=Persistent sync /mnt/data → /opt/infinity_x_one → GitHub
After=network.target

[Service]
ExecStart=/opt/infinity_x_one/scripts/persistent_sync.sh
WorkingDirectory=/opt/infinity_x_one
Restart=always
User=infinity-x-one

[Install]
WantedBy=multi-user.target
EOF

# Create sync script
cat <<'EOF' > /opt/infinity_x_one/scripts/persistent_sync.sh
#!/bin/bash
while true; do
  rsync -av --exclude=node_modules /mnt/data/ /opt/infinity_x_one/
  cd /opt/infinity_x_one
  git add .
  git commit -m "🔁 AutoSync $(date)"
  git push origin main
  sleep 300  # 5 minutes
done
EOF

chmod +x /opt/infinity_x_one/scripts/persistent_sync.sh

### 3. 🌀 Reload + restart
systemctl daemon-reload
systemctl enable persistent-sync.service
systemctl restart persistent-sync.service

### 4. ✅ Reload ENV across cron + agent
echo "@reboot source /opt/infinity_x_one/scripts/load_env.sh" >> /var/spool/cron/crontabs/infinity-x-one

echo "✅ Final patch complete — all services synchronized."
