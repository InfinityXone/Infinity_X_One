#!/bin/bash

### ─────────────────────────────────────────────
### Infinity X One — SuperBash Init Protocol
### Bootstraps unified agent ignition, logging, summary unpack, and diagnostics
### Author: PromptWriter (Agent Mode)
### Location: /opt/infinity_x_one/superbash_infinity_init.sh
### ─────────────────────────────────────────────

REPORT_DIR="/opt/infinity_x_one/Records"
mkdir -p "$REPORT_DIR"
echo "📁 Created record directory: $REPORT_DIR"

# Step 1: Unpack zipped summary if found
ZIP_PATH="/mnt/data/Infinity_X_One_Summary_Pack.zip"
if [[ -f "$ZIP_PATH" ]]; then
  echo "📦 Unpacking Infinity_X_One_Summary_Pack.zip..."
  unzip -o "$ZIP_PATH" -d "$REPORT_DIR/Infinity_X_One_Summary_Pack"
  echo "✅ Unpacked to: $REPORT_DIR/Infinity_X_One_Summary_Pack"
else
  echo "⚠️  No zip archive found. Skipping unpack step."
fi

# Step 2: Agent runner + worker file scan
echo "🔍 Searching for all agent runners and workers..."
find /opt/infinity_x_one -type f \(
  -iname "*_worker.py" -o \
  -iname "agent_mode*.sh" -o \
  -iname "spawn_all_agents.sh" -o \
  -iname "agent_orchestrator.py" \
\) > "$REPORT_DIR/agent_runners_found.txt"
echo "✅ Agent runners listed in: $REPORT_DIR/agent_runners_found.txt"

# Step 3: Log search (last 15 lines each)
echo "🧠 Collecting tail of logs..."
LOG_SUMMARY="$REPORT_DIR/logs_summary.txt"
echo "" > "$LOG_SUMMARY"
find /opt/infinity_x_one -type f -name "*.log" | while read -r log_file; do
  echo "📝 $log_file" >> "$LOG_SUMMARY"
  tail -n 15 "$log_file" >> "$LOG_SUMMARY"
  echo "" >> "$LOG_SUMMARY"
done
echo "✅ Logs summarized to: $LOG_SUMMARY"

# Step 4: Crontab check
CRON_FILE="$REPORT_DIR/cron_check.txt"
echo "🕒 Crontab Output" > "$CRON_FILE"
crontab -l >> "$CRON_FILE" 2>&1
if [[ $(id -u) -eq 0 ]]; then
  echo "\n📋 Root crontab:" >> "$CRON_FILE"
  crontab -u root -l >> "$CRON_FILE" 2>&1
fi
ls -l /etc/cron.d >> "$CRON_FILE" 2>/dev/null
systemctl list-timers --all --no-pager | head -n 25 >> "$CRON_FILE"
echo "✅ Crontab summary saved to: $CRON_FILE"

# Step 5: Attempt to auto-launch swarm if spawn script exists
SPAWN_SCRIPT="/opt/infinity_x_one/spawn_all_agents.sh"
if [[ -f "$SPAWN_SCRIPT" ]]; then
  echo "🚀 Found: $SPAWN_SCRIPT — attempting to launch..."
  chmod +x "$SPAWN_SCRIPT"
  bash "$SPAWN_SCRIPT"
else
  echo "⚠️  Spawn script not found: $SPAWN_SCRIPT"
fi

# Completion notice
echo "✅ SuperBash Init Complete"
echo "📂 All outputs stored in: $REPORT_DIR"
