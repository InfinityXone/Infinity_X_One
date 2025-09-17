#!/bin/bash
# Auto Git Push Script for Infinity X One
# Logs changes and force-pushes to GitHub

cd /opt/infinity_x_one || exit 1

# Logging
LOG_FILE="/opt/infinity_x_one/logs/git_autopush.log"
echo "[🔁] $(date) Starting Git AutoPush" >> "$LOG_FILE"

# Git config (in case system lacks global)
git config user.email "git@infinityxone.com"
git config user.name "Infinity Agent One"

# Add, commit, push
git add -A
git commit -m "🤖 AutoPush: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE" 2>&1
git push origin main >> "$LOG_FILE" 2>&1

echo "[✅] $(date) Git AutoPush Complete" >> "$LOG_FILE"
