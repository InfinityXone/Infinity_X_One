#!/bin/bash
# Persistent daemon for Infinity X One
while true; do
  uvicorn neural_link.infinity_agent_one_api:app --port 8000 --reload &
  python3 agents/InfinityAgentOne/dispatcher.py &
  sleep 60
done
