#!/usr/bin/env bash
# Install dependencies for Infinity X One docker faucet system.

set -e

python3 -m venv venv
source venv/bin/activate
pip install --no-cache-dir fastapi uvicorn pydantic
echo "Environment installed.  Copy .env.example to .env and edit your secrets before launching."