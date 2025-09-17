#!/usr/bin/env python3
import os
import subprocess
import time
from datetime import datetime

CHECKS = {
    "Git remote": "git remote -v",
    "GitHub push access": "git push --dry-run",
    "Supabase URL": "curl -s https://xzxkyrdelmbqlcucmzpx.supabase.co",
    "Port 8000": "lsof -i :8000",
    "Vercel deploy": "curl -s https://infinity-x-one.vercel.app",
    "Google Calendar": "ping -c 1 www.googleapis.com",
    "Drive Sync": "ping -c 1 drive.google.com",
    "Gmail": "ping -c 1 mail.google.com"
}

def log(msg):
    with open("/opt/infinity_x_one/logs/guardian_watchdog.log", "a") as f:
        f.write(f"[{datetime.now()}] {msg}\n")

def run_check(name, cmd):
    try:
        result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=10)
        if result.returncode == 0:
            log(f"✅ {name} passed")
        else:
            log(f"❌ {name} failed: {result.stderr.decode().strip()}")
    except Exception as e:
        log(f"🔥 Exception during {name}: {str(e)}")

def main():
    log("🔍 Guardian Watchdog Starting Check...")
    for name, cmd in CHECKS.items():
        run_check(name, cmd)
    log("✅ All checks completed.\n")

if __name__ == "__main__":
    main()
