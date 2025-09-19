#!/bin/bash
# Infinity X One - Parallel Setup for Persistent Memory + Hydration + Seed

LOG_FILE="/opt/infinity_x_one/logs/memory_system_setup.log"
SQL_DIR="/mnt/data/sql"

echo "[$(date)] 🚀 Starting Memory System Setup..." | tee -a "$LOG_FILE"

# Apply migrations
for file in "$SQL_DIR"/*.sql; do
  if [ -f "$file" ]; then
    echo "[$(date)] 📂 Applying Supabase migration: $file" | tee -a "$LOG_FILE"
    supabase db push --yes | tee -a "$LOG_FILE"
  fi
done

# Copy hydration script
cp /mnt/data/agents/memory_hydrate.py /opt/infinity_x_one/agents/
chmod +x /opt/infinity_x_one/agents/memory_hydrate.py

# Install systemd unit
cp /mnt/data/systemd/agent_memory.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable agent_memory
systemctl start agent_memory

echo "[$(date)] ✅ Memory system installed, seeded, and active." | tee -a "$LOG_FILE"

