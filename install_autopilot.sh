#!/bin/bash

# === install_autopilot.sh ===
# Installs Infinity Autopilot system:
# - /opt/scripts
# - /opt/_autopilot
# - Core scripts: autopilot.sh, data_sync.sh, git_push_pull.sh

echo "🚀 Starting Infinity Autopilot Install..."

# Create folders
mkdir -p /opt/scripts
mkdir -p /opt/_autopilot

# Create log files
touch /opt/_autopilot/sync.log
touch /opt/_autopilot/git.log
touch /opt/_autopilot/autopilot_stdout.log

# --- autopilot.sh ---
cat << 'EOF' > /opt/scripts/autopilot.sh
#!/bin/bash
exec >> /opt/_autopilot/autopilot_stdout.log 2>&1
echo "🚀 Autopilot started at \$(date)"
while true; do
  echo "🔁 Loop running at \$(date)"
  if [ -x /opt/scripts/data_sync.sh ]; then
    /opt/scripts/data_sync.sh
  else
    echo "❌ data_sync.sh not executable or missing"
  fi
  if [ -x /opt/scripts/git_push_pull.sh ]; then
    /opt/scripts/git_push_pull.sh
  else
    echo "❌ git_push_pull.sh not executable or missing"
  fi
  sleep 10
done
EOF

# --- data_sync.sh ---
cat << 'EOF' > /opt/scripts/data_sync.sh
#!/bin/bash
SRC="/mnt/data"
DST="/opt"
echo "🔁 Running rsync from \$SRC to \$DST"
rsync -a --delete "\$SRC/" "\$DST/"
echo "✅ [\$(date)] Sync complete" >> /opt/_autopilot/sync.log
EOF

# --- git_push_pull.sh ---
cat << 'EOF' > /opt/scripts/git_push_pull.sh
#!/bin/bash
for dir in /opt/*/; do
  if [ -d "\$dir/.git" ]; then
    cd "\$dir" || continue
    echo "📁 Syncing Git repo: \$dir"
    git add . > /dev/null 2>&1
    git commit -m "🔄 Auto-sync: \$(date)" > /dev/null 2>&1
    git push origin main > /dev/null 2>&1 && echo "⬆️  [\$dir] Push OK"
    git pull origin main > /dev/null 2>&1 && echo "⬇️  [\$dir] Pull OK"
    echo "✅ [\$dir] Git synced @ \$(date)" >> /opt/_autopilot/git.log
  fi
done
EOF

# Set permissions
chmod +x /opt/scripts/*.sh

echo "✅ Autopilot installed."
echo "📂 Scripts: /opt/scripts"
echo "📂 Logs: /opt/_autopilot"
echo "🚀 Run manually: bash /opt/scripts/autopilot.sh"
