#!/bin/bash
# 🧪 Test Memory Sync Script for Infinity X One

LOGFILE="/opt/infinity_x_one/logs/test_memory.log"
SUPABASE_URL=$(grep SUPABASE_URL /opt/infinity_x_one/env/supabase.env | cut -d= -f2)
SUPABASE_KEY=$(grep SUPABASE_SERVICE_KEY /opt/infinity_x_one/env/supabase.env | cut -d= -f2)

echo "🚀 Running test_memory.sh at $(date)" >> "$LOGFILE"

# Insert a Rosetta test memory row
TEST_ENTRY="{\"key\":\"test_memory\",\"value\":{\"msg\":\"Hello from Infinity 🌀 at $(date)\"}}"
curl -s "$SUPABASE_URL/rest/v1/rosetta_memory" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d "$TEST_ENTRY" >> "$LOGFILE" 2>&1

echo "✅ Test entry sent to rosetta_memory table" >> "$LOGFILE"
