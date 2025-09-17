#!/bin/bash

# Script: run_test_pipeline.sh
# Purpose: Test GPT ➜ /mnt/data ➜ /opt ➜ Git commit ➜ GitHub ➜ Runner

echo "🚀 Creating test file in /mnt/data..."
echo "🚀 TEST FILE: GPT to MNT to OPT to Git pipeline test." > /mnt/data/test_payload_from_gpt.txt

echo "📦 Copying file to /opt/infinity_x_one..."
sudo cp /mnt/data/test_payload_from_gpt.txt /opt/infinity_x_one/

cd /opt/infinity_x_one || exit 1

echo "📚 Git staging..."
git add test_payload_from_gpt.txt

echo "📝 Committing to Git..."
git commit -m '✅ Pipeline Test: MNT to OPT to Git successful'

echo "📤 Pushing to GitHub..."
git push origin main

echo "✅ Pipeline test complete."
