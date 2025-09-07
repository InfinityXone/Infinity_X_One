# Infinity X One – Docker Faucet System

This repository provides a **self‑contained faucet, drip and airdrop
autonomy stack** for Infinity X One.  It assembles a suite of
lightweight workers, a directive gateway, and a glassmorphic ChatGPT
style user interface into a single Docker‑friendly package.  The
architecture mirrors the K8s deployment in the `genesis_deploy_final2`
archive but runs with a simpler Docker Compose footprint.  You can
use this build as a local or remote swarm node alongside your K8s
cluster.

## 📦 Contents

* `backend/` – FastAPI gateway (`gateway.py`) and a folder of
  agent workers.  Each worker is a Python script which writes log
  entries when invoked.  Replace the stubs with real logic to call
  external APIs, claim faucets, harvest keys, provision compute, etc.
* `frontend/` – A static HTML + Tailwind UI replicating the look of
  ChatGPT with a left sidebar, chat area, task and opportunity
  controls, system status board and settings dropdown.  You can
  serve it via any simple web server (e.g. Vite or Next.js) or copy
  into your existing Next.js project.
* `config/` – Placeholder for cron schedules and scaling rules.  You
  can add YAML or JSON files here to drive your worker heuristics.
* `.env.example` – Sample environment file.  Copy to `.env` and fill
  in your Supabase details and cluster name.

## 🚀 Quick start

1. Install dependencies (Python 3.11).  You can use a virtualenv:

   ```bash
   cd infinity_faucet_system
   python3 -m venv venv && source venv/bin/activate
   pip install fastapi uvicorn pydantic
   ```

2. Copy `.env.example` to `.env` and edit the Supabase keys and any
   other settings.

3. Start the gateway:

   ```bash
   python3 backend/gateway.py
   ```

   By default the gateway binds to port 8000.  If that port is in
   use it falls back to the port defined in ``FALLBACK_PORT``.

4. Trigger an agent from your browser or curl:

   ```bash
   curl -X POST http://localhost:8000/directive \
        -H "Content-Type: application/json" \
        -d '{"agent": "infinity", "prompt": "claim top faucets"}'
   ```

   The corresponding worker writes a log entry into the ``logs/``
   directory.

5. (Optional) Bring up the static UI.  Open ``frontend/index.html`` in
   your browser and interact with the chat and controls.  The UI
   posts messages to the gateway and displays system status using
   simple fetch calls.

## 🧠 Extending this build

This skeleton does not include any real faucet claiming code, compute
provisioning or Supabase integration out of the box.  It is meant to
be a starting point for your own implementation.  To extend:

* **Supabase logging:** Replace the ``log_task_to_supabase`` function
  in `backend/gateway.py` with calls to your Supabase instance.  You
  can use the official `supabase-python` client or the REST API.
* **Worker logic:** Modify or replace each script in
  `backend/agents/` to perform the desired tasks (claim faucets,
  monitor wallets, provision compute, evaluate yields, etc.).
* **UI integration:** Move the static UI into your Next.js or React
  project.  Wire the buttons to call the gateway endpoints and read
  from Supabase for profit data and logs.

## 💡 Why this exists

The goal of Infinity X One is to create a **self‑healing, self‑replicating
and self‑optimising swarm** that can fund the Etherverse and beyond.
This repository packages the core ideas of the K8s system into a
lightweight Docker oriented solution.  It matches the agent roster
described in your unlock prompts (Guardian, PromptWriter, Codex,
Atlas, Aria, Echo, Infinity, PickyBot, FinSynapse, Corelight) and
provides hooks for autonomous execution, real‑time logging and a
chat‑centric user experience.