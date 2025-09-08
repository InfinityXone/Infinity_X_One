#!/usr/bin/env python3
import logging, subprocess, time, psutil, json
from datetime import datetime

#  Setup structured logging
logging.basicConfig(
    filename='/opt/infinity_x_one/logs/hive_orchestrator.log',
    level=logging.INFO,
    format='%(asctime)s [%(name)s] %(levelname)s: %(message)s'
)

def run_task(cmd, name, retries=1, backoff=5):
    logger = logging.getLogger(name)
    for attempt in range(1, retries + 2):
        try:
            subprocess.run(cmd, shell=True, check=True)
            logger.info(f"{name} → SUCCESS")
            return True
        except Exception as e:
            logger.error(f"{name} attempt {attempt}/{retries+1} → FAIL: {e}")
            if attempt <= retries:
                time.sleep(backoff * attempt)
    return False

def log_system_health():
    usage = {
        "cpu_percent": psutil.cpu_percent(),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage('/').percent
    }
    logging.getLogger("SystemHealth").info(json.dumps(usage))

def orchestrate():
    logging.info("=== Hive Orchestrator START ===")
    log_system_health()

    tasks = [
        ("bash scripts/system_diagnostic.sh", "Diagnostic", 1),
        ("bash scripts/backup_to_drive.sh", "BackupDrive", 0),
        ("bash rosetta_memory.sh", "RosettaSync", 1),
        ("bash agents/fin_synapse_tracker.sh", "FinSynapse", 0),
        ("bash agents/faucet_monitor.sh", "FaucetMonitor", 0),
        ("curl -sf http://localhost:8000/status || systemctl restart handshake_server", "HandshakeHealth", 0),
        ("cd /opt/infinity_x_one && git add . && git commit -m \"Auto-sync $(date)\" && git push origin main", "GitHubSync", 0),
        ("supabase db push --project-ref YOUR_PROJECT_REF", "SupabaseDeploy", 0),
        ("vercel --prod", "VercelDeploy", 0),
        ("rclone sync /opt/infinity_x_one/records remote:InfinityXOneBackup", "GoogleDriveSync", 0)
    ]

    for cmd, name, retries in tasks:
        run_task(cmd, name, retries)

    logging.info("=== Hive Orchestrator END ===\n")

if __name__ == "__main__":
    orchestrate()

