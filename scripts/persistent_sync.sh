#!/bin/bash
while true; do
  rsync -av --exclude=node_modules /mnt/data/ /opt/infinity_x_one/
  cd /opt/infinity_x_one
  git add .
  git commit -m "🔁 AutoSync $(date)"
  git push origin main
  sleep 300  # 5 minutes
done
