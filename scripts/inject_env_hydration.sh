#!/bin/bash
# === Infinity X One Agent ENV Injector ===

AGENT_DIR="/opt/infinity_x_one/agents"
STAMP="# 🌐 Modified by GPT @ $(date '+%Y-%m-%d %H:%M:%S')"

ENV_BLOCK=$(cat <<'EOF'
# === Infinity X One ENV Hydration System ===
from dotenv import load_dotenv
import os

ENV_PATH = "/opt/infinity_x_one/env"

def hydrate_env():
    try:
        for filename in os.listdir(ENV_PATH):
            if filename.endswith(".env"):
                load_dotenv(os.path.join(ENV_PATH, filename), override=True)
        print(f"✅ ENV hydrated from: {ENV_PATH}")
    except Exception as e:
        print(f"⚠️ ENV hydration failed: {e}")

hydrate_env()
EOF
)

echo "🔍 Injecting into agents in: $AGENT_DIR"

for file in "$AGENT_DIR"/*.py; do
    if grep -q "ENV_PATH = \"/opt/infinity_x_one/env\"" "$file"; then
        echo "✅ Already injected: $(basename "$file")"
    else
        echo "💉 Injecting: $(basename "$file")"
        tmpfile=$(mktemp)
        echo "$STAMP" > "$tmpfile"
        echo "$ENV_BLOCK" >> "$tmpfile"
        cat "$file" >> "$tmpfile"
        mv "$tmpfile" "$file"
    fi
done

echo "✅ Injection complete."
