#!/bin/bash
cd /opt/infinity_x_one

git add agents/ guardian/ supabase/migrations/ docs/ scripts/
git commit -m "🤖 Infinity Agent One Full Unlock: Conversational UI + Personality Blueprint + Groq/OpenAI relay"
git push origin main

git tag -a vAgent-One-Full-Unlock -m "Agent One now has full personality, natural language, Groq/OpenAI dual LLM, Rosetta rehydration, Supabase logging, and GPT UI relay."
git push origin vAgent-One-Full-Unlock
