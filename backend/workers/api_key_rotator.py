"""API key rotation utilities for Infinity X One.

This module provides functions to manage a pool of API keys used by
various workers (for example, the ``FaucetHunter`` when claiming
faucets).  Keys can be supplied via environment variables, stored in
a JSON file, or harvested by the ``KeyHarvester`` worker.  Rotation
state is persisted so that each new claim uses a different key, which
helps distribute traffic across multiple provider accounts and avoid
rate limiting.

**Configuration**::

    export API_KEYS="key1,key2,key3"
    export API_KEYS_STORE_FILE="/path/to/api_keys.json"
    export API_KEY_ROTATION_STATE_FILE="/path/to/rotation_state.json"

You can specify a comma separated list of keys in ``API_KEYS`` to
bootstrap the store.  The ``KeyHarvester`` worker writes new keys
into the local store using ``append_api_keys``.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Dict, List

from ..supabase_utils import insert_log


# File used to persist harvested keys.  Can be overridden via the
# ``API_KEYS_STORE_FILE`` environment variable.
def _store_path() -> Path:
    custom = os.getenv("API_KEYS_STORE_FILE")
    if custom:
        return Path(custom)
    return Path(__file__).resolve().parent / "api_keys_store.json"


# File used to persist rotation state (current index).  Can be
# overridden via ``API_KEY_ROTATION_STATE_FILE``.
def _rotation_state_path() -> Path:
    custom = os.getenv("API_KEY_ROTATION_STATE_FILE")
    if custom:
        return Path(custom)
    return Path(__file__).resolve().parent / "api_key_rotation_state.json"


def _load_api_keys() -> List[str]:
    """Load the list of API keys from the store and environment variables.

    The environment variable ``API_KEYS`` has priority and will be
    merged with any keys already present in the store.  Duplicates are
    removed.  If the resulting list is empty, a single placeholder
    string is returned.
    """
    keys: List[str] = []
    # Load keys from environment variable
    env_keys = os.getenv("API_KEYS")
    if env_keys:
        parts = [k.strip() for k in env_keys.split(",") if k.strip()]
        keys.extend(parts)
    # Load keys from the store file
    store_file = _store_path()
    if store_file.exists():
        try:
            with store_file.open("r") as f:
                data = json.load(f)
                if isinstance(data, list):
                    keys.extend([str(k).strip() for k in data if str(k).strip()])
        except Exception:
            pass
    # Deduplicate while preserving order
    seen = set()
    unique: List[str] = []
    for k in keys:
        if k not in seen:
            unique.append(k)
            seen.add(k)
    return unique or ["stubbed-api-key"]


def _load_rotation_state() -> Dict[str, int]:
    """Load the API key rotation state from disk.

    Returns a dict with at least the key ``index``.  If the file
    doesn't exist or cannot be parsed, returns ``{"index": 0}``.
    """
    path = _rotation_state_path()
    if path.exists():
        try:
            with path.open("r") as f:
                data = json.load(f)
                if isinstance(data, dict) and "index" in data:
                    return {"index": int(data["index"])}
        except Exception:
            pass
    return {"index": 0}


def _save_rotation_state(state: Dict[str, int]) -> None:
    """Persist the API key rotation state to disk."""
    path = _rotation_state_path()
    try:
        with path.open("w") as f:
            json.dump(state, f)
    except Exception as e:
        insert_log(
            "agent_logs",
            {
                "agent": "APIKeyRotator",
                "event": "api_key_rotation_save_error",
                "details": str(e),
            },
        )


def get_next_api_key() -> str:
    """Return the next API key in the rotation.

    This function reads the current list of keys and rotation state,
    selects the key at the current index, advances the index and
    persists it.  If only one key is available, the same key is
    returned on each call.
    """
    keys = _load_api_keys()
    state = _load_rotation_state()
    index = state.get("index", 0)
    if not keys:
        return "stubbed-api-key"
    index = index % len(keys)
    key = keys[index]
    state["index"] = (index + 1) % len(keys)
    _save_rotation_state(state)
    return key


def append_api_keys(new_keys: Dict[str, str]) -> None:
    """Append new keys to the store file.

    ``new_keys`` should be a mapping from provider name to key.  The
    values are extracted and appended to the existing store list.  This
    function will create the store file if it doesn't exist.
    """
    store_file = _store_path()
    keys: List[str] = []
    # Load existing
    if store_file.exists():
        try:
            with store_file.open("r") as f:
                data = json.load(f)
                if isinstance(data, list):
                    keys.extend([str(k).strip() for k in data if str(k).strip()])
        except Exception:
            pass
    # Append new values
    for _, value in new_keys.items():
        value = str(value).strip()
        if value and value not in keys:
            keys.append(value)
    try:
        with store_file.open("w") as f:
            json.dump(keys, f)
    except Exception as e:
        insert_log(
            "agent_logs",
            {
                "agent": "APIKeyRotator",
                "event": "api_keys_store_error",
                "details": str(e),
            },
        )