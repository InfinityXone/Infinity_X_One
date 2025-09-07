#!/bin/bash
set -euo pipefail
SUBJECT="${1:-}"
MODE="${2:-Deep-Dive}"   # or Quick-Scan
if [[ -z "$SUBJECT" ]]; then
  echo "usage: strategize \"<subject>\" [Deep-Dive|Quick-Scan]"
  exit 1
fi
slug=$(echo "$SUBJECT" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//')
ts=$(date +"%Y-%m-%d_%H-%M")
BASE="/opt/infinity_x_one/strategy_sessions/${ts}_${slug}"
mkdir -p "$BASE"
# link the canonical system prompt
ln -sf /opt/infinity_x_one/prompts/strategy/strategy_gpt_system.txt "$BASE/strategy_prompt.txt"

# create a ready-to-fill template with section headers
cat > "$BASE/notes.md" <<EOF
# Strategy Session — ${SUBJECT}
- Mode: ${MODE}
- Timestamp: ${ts}
- Owner: ${USER}

## 0) Executive Summary (5 bullets max)

## 1) Primer (definitions, value chain)

## 2) State of the Art (last 6–12 months) — cite

## 3) Market Map & Competitors
| Segment | Player | Offering | Price/Model | Traction/Scale | Strength | Weakness | Moat/Notes |
|---|---|---|---|---|---|---|---|

## 4) Customers & Use Cases (ICPs, JTBD)

## 5) Data & Benchmarks (unit economics; show math)

## 6) Risks & Constraints (+ mitigations)

## 7) Little-Known Facts & Pro Tips

## 8) Ten Highly Profitable Strategies

## 9) Ten Business Models You Can Launch Now

## 10) Step-by-Step Venture Plan (30/60/90)

## 11) Implementation Guide (arch, commands, env, CI)

## 12) Go-to-Market Plan (positioning, channels, pricing tests)

## 13) Financial Model Skeleton (assumptions + sensitivity)

## 14) Resource Pack (links + why it matters)

## 15) Action Items (next 48h: owner / effort / dependency / outcome)
EOF

echo "✅ Strategy session created at: $BASE"
echo "   Open with: nano \"$BASE/notes.md\""
