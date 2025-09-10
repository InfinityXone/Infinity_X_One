#!/usr/bin/env bash
set -euo pipefail
echo "=== CLI Sanity Check ==="
command -v gh && gh auth status || echo "[!] GitHub not ready"
command -v supabase && supabase --version || echo "[!] Supabase CLI missing"
command -v vercel && vercel --version || echo "[!] Vercel CLI missing"
command -v rclone && rclone version || echo "[!] rclone missing"
command -v gcloud && gcloud version || echo "[!] gcloud missing"
echo "=== Check Complete ==="
