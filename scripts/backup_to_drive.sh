#!/bin/bash
set -euo pipefail
rclone sync /opt/infinity_x_one gdrive:/Infinity_Backups --log-file /opt/infinity_x_one/logs/backup.log --log-level INFO
