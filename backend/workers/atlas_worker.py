"""Atlas worker.

Atlas is responsible for provisioning new compute resources for the
faucet swarm.  In the initial genesis release this module generated
stub nodes to illustrate how Supabase integration works.  In the
production system we shift to a *remote‑first* strategy: by default the
worker attempts to create real cloud instances using whichever cloud
provider is configured.  If no provider is configured or a request
fails, the worker falls back to the stub implementation so the swarm can
continue operating locally.

Configuration is controlled via environment variables:

```
export ATLAS_PROVIDER="vastai"        # or "runpod", "aws", "gcp"
export ATLAS_API_KEY="<your provider API key>"
export ATLAS_REGION="us-east-1"
```

When `ATLAS_PROVIDER` and `ATLAS_API_KEY` are set, the `provision_node`
function makes a simple API request to the corresponding provider.  Only
`vastai` and `runpod` are sketched out in code; other providers will
fall back to the stub.  Extend this function with real API calls as
needed.  All provisioned nodes are recorded in the ``compute_nodes``
table and logged to ``agent_logs``.
"""

import time
import random
import os
from typing import Dict, Optional

import json

import requests

from ..supabase_utils import fetch_pending_directives, insert_log, mark_directive_complete

AGENT_NAME = "Atlas"

# Example regions and dummy endpoints used for stub nodes
REGIONS = ["us-east-1", "us-west-2", "eu-central-1"]


def provision_node(region: str) -> Dict[str, str]:
    """Provision a compute node.

    The behaviour depends on the configured provider.  If no provider is
    configured (via ``ATLAS_PROVIDER``), a stub node is returned after a
    brief delay.  Supported providers include ``vastai`` and ``runpod``.

    Parameters
    ----------
    region : str
        Desired region for the new node.

    Returns
    -------
    Dict[str, str]
        A dictionary describing the node.  Keys include ``region``,
        ``endpoint`` and ``status``.
    """
    provider = os.getenv("ATLAS_PROVIDER")
    api_key = os.getenv("ATLAS_API_KEY")
    # If provider or key is missing, fall back to stub
    if not provider or not api_key:
        time.sleep(1)
        return {
            "region": region,
            "endpoint": f"https://{region}.dummy-provider.com/{random.randint(1000, 9999)}",
            "status": "active",
        }

    # Only minimal examples for demonstration.  Real implementations
    # should perform proper error handling, authentication and resource
    # configuration.
    try:
        if provider.lower() == "vastai":
            # Example call to Vast.ai API for a free on-demand instance.
            # See https://vast.ai/api/v0/docs/ for details.  This call
            # uses a placeholder payload and does not create a real
            # instance.  Replace with actual API parameters.
            url = "https://api.vast.ai/instances"  # fictitious endpoint
            headers = {"Authorization": f"Bearer {api_key}"}
            payload = {
                "region": region,
                "image": "ubuntu:latest",
                "min_memory": 4,
                "min_vcpus": 2,
            }
            resp = requests.post(url, headers=headers, json=payload, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            # In a real call, parse the response for connection details
            return {
                "region": region,
                "endpoint": data.get("endpoint", "unknown"),
                "status": data.get("status", "pending"),
            }
        if provider.lower() == "runpod":
            # Example call to RunPod serverless API.  The runpod.io
            # documentation defines how to create GPU containers.  This
            # payload is illustrative only.
            url = "https://api.runpod.io/v2/workspace"  # fictitious endpoint
            headers = {"Authorization": api_key}
            payload = {
                "region": region,
                "container": {
                    "image": "python:3.11-slim",
                    "command": ["sleep", "infinity"],
                    "resources": {"cpu": 1, "memory": 4},
                },
            }
            resp = requests.post(url, headers=headers, json=payload, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            return {
                "region": region,
                "endpoint": data.get("endpoint", "unknown"),
                "status": data.get("status", "pending"),
            }
    except Exception as e:
        # Log the error; fallback to stub
        insert_log(
            "agent_logs",
            {
                "agent": AGENT_NAME,
                "event": "compute_provision_error",
                "details": str(e),
            },
        )
    # Fallback: stub
    time.sleep(1)
    return {
        "region": region,
        "endpoint": f"https://{region}.dummy-provider.com/{random.randint(1000, 9999)}",
        "status": "active",
    }


def process_directive(directive: Dict) -> None:
    directive_id = directive["id"]
    command = directive["command"]
    payload = directive.get("payload", {})

    if command == "PROVISION_NODES":
        count = payload.get("count", 1)
        new_nodes = []
        for i in range(count):
            region = random.choice(REGIONS)
            node = provision_node(region)
            new_nodes.append(node)
            insert_log("compute_nodes", {"agent": AGENT_NAME, **node})
        insert_log("agent_logs", {"agent": AGENT_NAME, "event": "provisioned_nodes", "details": new_nodes})
    else:
        insert_log("agent_logs", {"agent": AGENT_NAME, "event": "unknown_directive", "details": command})

    mark_directive_complete(directive_id)


def run_worker() -> None:
    while True:
        directives = fetch_pending_directives(AGENT_NAME)
        if directives:
            process_directive(directives[0])
        else:
            # Idle until requested; Atlas is on‑demand
            time.sleep(300)


if __name__ == "__main__":
    run_worker()
