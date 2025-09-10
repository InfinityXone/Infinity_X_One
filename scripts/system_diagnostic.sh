#!/bin/bash
set -euo pipefail

OUT="/opt/infinity_x_one/records/system_diagnostic_$(date +%F_%H-%M-%S).log"

echo "🌌 Infinity X One Full System Diagnostic — $(date)" > "$OUT"
echo "=================================================" >> "$OUT"

# 1. Cron jobs
echo -e "\n=== CRONTAB (user) ===" >> "$OUT"
crontab -l >> "$OUT" 2>&1

echo -e "\n=== /etc/crontab ===" >> "$OUT"
sudo cat /etc/crontab >> "$OUT" 2>&1 || echo "No system crontab" >> "$OUT"

echo -e "\n=== /etc/cron.d/ ===" >> "$OUT"
ls -l /etc/cron.d/ >> "$OUT" 2>&1

# 2. Systemd timers & services
echo -e "\n=== SYSTEMD TIMERS ===" >> "$OUT"
systemctl list-timers --all >> "$OUT" 2>&1

echo -e "\n=== SYSTEMD SERVICES (infinity) ===" >> "$OUT"
systemctl list-unit-files | grep infinity >> "$OUT" 2>&1
systemctl status hive_orchestrator.service >> "$OUT" 2>&1 || true
systemctl status handshake_server.service >> "$OUT" 2>&1 || true

# 3. Folder map
echo -e "\n=== /opt/infinity_x_one Folder Tree ===" >> "$OUT"
tree -a -L 3 /opt/infinity_x_one -I "node_modules|__pycache__|.git|venv|.next" >> "$OUT" 2>&1

# 4. Agent + worker scripts
echo -e "\n=== Agents & Workers ===" >> "$OUT"
ls -l /opt/infinity_x_one/agents >> "$OUT" 2>&1 || true
ls -l /opt/infinity_x_one/backend/workers >> "$OUT" 2>&1 || true

# 5. Supabase schema (if CLI installed)
echo -e "\n=== Supabase Schema ===" >> "$OUT"
if command -v supabase >/dev/null 2>&1; then
  supabase db dump >> "$OUT" 2>&1
else
  echo "Supabase CLI not installed or not in PATH" >> "$OUT"
fi

# 6. Logs snapshot
echo -e "\n=== Last 50 lines of Key Logs ===" >> "$OUT"
for f in /opt/infinity_x_one/logs/*.log /var/log/infinity_x_one/*.log; do
  if [ -f "$f" ]; then
    echo -e "\n--- $f ---" >> "$OUT"
    tail -n 50 "$f" >> "$OUT"
  fi
done

# 7. Git remote & status
echo -e "\n=== Git Status ===" >> "$OUT"
cd /opt/infinity_x_one && git remote -v >> "$OUT"
git status >> "$OUT"

echo -e "\n✅ Diagnostic complete. File saved to: $OUT"
