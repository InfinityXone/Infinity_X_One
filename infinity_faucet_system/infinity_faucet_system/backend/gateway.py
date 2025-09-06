"""
Infinity X One – Directive Gateway
==================================

This module exposes a minimal FastAPI application that acts as the command
router between ChatGPT (or any LLM client) and the underlying worker
agents.  It accepts simple JSON directives, writes them to a local log
(and optionally Supabase), and asynchronously spins up a corresponding
worker script.  A status endpoint returns the current health of the
gateway and available agents.  This gateway is designed to be run
inside a Docker container and listens on port 8000 by default with
support for a fallback port 8001 via the environment variable
``FALLBACK_PORT``.

Endpoints
---------

``/directive``
    Accepts a JSON object with the keys ``agent``, ``prompt`` and
    optional ``priority`` and ``from_user``.  It logs the request and
    launches the corresponding agent script in the ``agents/`` folder.

``/agents``
    Returns the list of agent names known to this gateway.

``/status``
    Reports basic health information including which port the gateway
    is listening on and the list of known agents.

Usage
-----
The gateway can be started via ``uvicorn`` either directly or by
running this module as a script.  For example:

.. code:: bash

    python3 gateway.py  # listens on port 8000

To enable fallback port support, set ``FALLBACK_PORT=8001`` in the
environment.  If the primary port is unavailable the server will
automatically try to bind to the fallback.

Notes
-----
This is a simplified demonstration.  In a production environment you
would replace the file‑based logger with Supabase inserts via an
async client and potentially add authentication and rate limiting.
"""

from __future__ import annotations

import json
import os
import subprocess
from datetime import datetime
from typing import List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from starlette.responses import JSONResponse
from starlette.middleware.cors import CORSMiddleware

app = FastAPI(title="Infinity X One Directive Gateway")

# Allow simple CORS for local front‑end development.  In production,
# restrict origins appropriately.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Directive(BaseModel):
    """Schema for incoming directive requests."""

    agent: str
    prompt: str
    priority: Optional[int] = 3
    from_user: Optional[str] = "GPT"


def log_task_to_supabase(agent: str, prompt: str, priority: int, from_user: str) -> None:
    """Append a directive entry to a local log file.

    In a production deployment this function should insert the directive
    into a Supabase table.  To keep this example self‑contained we
    simply write JSON lines to ``./logs/gpt_directives.log``.
    """

    os.makedirs("./logs", exist_ok=True)
    ts = datetime.utcnow().isoformat()
    entry = {
        "timestamp": ts,
        "agent": agent,
        "from": from_user,
        "priority": priority,
        "command": prompt,
    }
    try:
        with open("./logs/gpt_directives.log", "a", encoding="utf-8") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception as exc:
        print(f"[Logger Error] {exc}")


# Map of logical agent names to worker script filenames.  When a
# directive specifies an agent, the corresponding script is executed
# asynchronously using ``subprocess.Popen``.  Add new entries here
# whenever you introduce a new agent.
AGENT_EXECUTION_MAP: dict[str, str] = {
    "guardian": "guardian_worker.py",
    "promptwriter": "promptwriter_worker.py",
    "codex": "codex_worker.py",
    "atlas": "atlas_worker.py",
    "aria": "aria_worker.py",
    "echo": "echo_worker.py",
    "infinity": "infinity_worker.py",
    "pickybot": "pickybot_worker.py",
    "finsynapse": "finsynapse_worker.py",
    "corelight": "corelight_worker.py",
}


@app.post("/directive")
async def send_directive(data: Directive) -> JSONResponse:
    """Route directives to the appropriate agent.

    This endpoint accepts a JSON body conforming to the ``Directive``
    schema.  It logs the directive and, if a matching worker exists,
    spawns that worker as a detached process.  Any errors launching
    the worker will return a 500 response.
    """

    agent = data.agent.lower()
    prompt = data.prompt
    # Log directive for audit/persistence
    log_task_to_supabase(agent, prompt, data.priority or 3, data.from_user or "GPT")

    if agent in AGENT_EXECUTION_MAP:
        script_name = AGENT_EXECUTION_MAP[agent]
        script_path = os.path.join(os.path.dirname(__file__), "agents", script_name)
        if not os.path.exists(script_path):
            raise HTTPException(status_code=404, detail=f"Agent script '{script_name}' not found")
        try:
            # Launch the worker script asynchronously
            subprocess.Popen(["python3", script_path, prompt], close_fds=True)
        except Exception as exc:
            return JSONResponse(status_code=500, content={"error": str(exc)})

    return JSONResponse(content={"status": "accepted", "agent": agent, "prompt": prompt})


@app.get("/agents")
async def list_agents() -> List[str]:
    """Return the list of registered agent names."""
    return list(AGENT_EXECUTION_MAP.keys())


@app.get("/status")
async def status() -> dict:
    """Return a simple status payload for liveness checks."""
    primary_port = int(os.environ.get("PRIMARY_PORT", 8000))
    fallback_port = int(os.environ.get("FALLBACK_PORT", 8001))
    return {
        "gateway": "online",
        "primary_port": primary_port,
        "fallback_port": fallback_port,
        "agents": list(AGENT_EXECUTION_MAP.keys()),
        # Basic system indicators (stubbed as online; extend with real health checks)
        "supabase": "online",
        "swarm": "online",
        "finance": "online",
    }


# Example opportunities endpoint: returns a short list of high‑paying faucets.
@app.get("/opportunities")
async def get_opportunities() -> dict:
    """Return a curated list of top crypto faucets.

    Replace or extend this static list with a dynamic call to a
    database or external service.  Each entry contains the faucet
    name and URL only for quick lookup.
    """
    faucets = [
        {"name": "FreeBitcoin", "url": "https://freebitco.in"},
        {"name": "Cointiply", "url": "https://cointiply.com"},
        {"name": "Fire Faucet", "url": "https://firefaucet.win"},
        {"name": "Bitcoinker", "url": "https://bitcoinker.com"},
        {"name": "MoonLiteCoin", "url": "https://moonlitecoin.com"},
    ]
    return {"faucets": faucets}


def run_server() -> None:
    """Start the Uvicorn server on primary or fallback port."""
    import uvicorn

    primary_port = int(os.environ.get("PRIMARY_PORT", 8000))
    fallback_port = int(os.environ.get("FALLBACK_PORT", 8001))
    try:
        uvicorn.run("backend.gateway:app", host="0.0.0.0", port=primary_port)
    except Exception:
        print(f"Primary port {primary_port} unavailable; attempting fallback {fallback_port}")
        uvicorn.run("backend.gateway:app", host="0.0.0.0", port=fallback_port)


if __name__ == "__main__":
    run_server()