#!/bin/bash

echo "=============================="
echo "📦 SYSTEM SNAPSHOT + DIAGNOSTICS"
echo "=============================="

# 📁 Show top-level folders and sizes
for DIR in / /opt /mnt /mnt/data /home /home/infinity-x-one/Downloads; do
  echo ""
  echo "📁 $DIR"
  sudo du -sh "$DIR"/* 2>/dev/null | sort -hr | head -n 10
done

echo ""
echo "=============================="
echo "💾 FILESYSTEM USAGE (df -hT)"
echo "=============================="
df -hT | grep -vE 'tmpfs|udev'

# 🧠 Run memory snapshot script
echo ""
echo "=============================="
echo "🧠 RUNNING: memory_snapshot_to_supabase.py"
echo "=============================="
python3 /opt/infinity_x_one/scripts/memory_snapshot_to_supabase.py

# 🧪 Supabase Connectivity Test
echo ""
echo "=============================="
echo "📡 TESTING Supabase Connection"
echo "=============================="
source /opt/infinity_x_one/env/supabase.env
curl -s -o /dev/null -w "%{http_code}\n" -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" "$SUPABASE_URL/rest/v1/"

# 💾 Save full directory tree snapshot
echo ""
echo "=============================="
echo "🧾 SAVING TREE SNAPSHOT TO /mnt/data"
echo "=============================="
tree -a -I 'node_modules|.git' /opt/infinity_x_one > /mnt/data/opt_infinity_x_one_tree_$(date +%s).txt

# 🧹 (Optional Preview) Files eligible for cleanup
echo ""
echo "=============================="
echo "🧹 PREVIEW FILES > 50MB"
echo "=============================="
sudo find /opt/infinity_x_one -type f -size +50M -exec ls -lh {} \; | awk '{ print $NF ": " $5 }'

echo ""
echo "✅ DONE: Snapshot complete. Ready for backup, cleanup, or Git push."
