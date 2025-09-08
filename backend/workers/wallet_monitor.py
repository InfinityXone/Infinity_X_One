"""WalletMonitor worker.

This worker tracks the balances of configured crypto wallets and records
those balances into Supabase.  The original genesis implementation
generated random numbers for demonstration purposes only.  In this
enhanced version we attempt to fetch real balances using the `web3`
library when it is available and a valid Ethereum RPC endpoint is
configured via the ``RPC_URL`` environment variable.  Wallet addresses
are specified through the ``WALLET_ADDRESSES`` environment variable as
a comma separated list.  If Web3 or the RPC URL is unavailable, or no
wallets are configured, the worker will fall back to generating random
balances to keep the system operational during development.

**Configuration**::

    export WALLET_ADDRESSES="0xYourWallet1,0xYourWallet2"
    export RPC_URL="https://mainnet.infura.io/v3/<YOUR_INFURA_ID>"

The worker logs into two Supabase tables: ``wallet_balances`` for
individual balance entries and ``agent_logs`` for heartbeat and error
events.
"""

import os
import time
import random
from typing import Dict, List

from ..supabase_utils import fetch_pending_directives, insert_log, mark_directive_complete

try:
    # Web3 is optional and may not be installed in all environments.
    from web3 import Web3  # type: ignore
except Exception:
    Web3 = None  # type: ignore

AGENT_NAME = "WalletMonitor"


def get_wallet_addresses() -> List[str]:
    """Return the wallet addresses configured via environment variables.

    Preferred configuration is to set ``WALLET_ADDRESSES`` to a comma
    separated list of wallet addresses.  Legacy variables
    ``BASE_PUBLIC_WALLET_KEY`` and ``ETHEREUM_ALTERNATE_WALLET_KEY`` are
    also supported.  If no addresses are provided, a placeholder is
    returned.
    """
    env_list = os.getenv("WALLET_ADDRESSES")
    if env_list:
        return [addr.strip() for addr in env_list.split(",") if addr.strip()]
    addresses: List[str] = []
    primary = os.getenv("BASE_PUBLIC_WALLET_KEY")
    secondary = os.getenv("ETHEREUM_ALTERNATE_WALLET_KEY")
    if primary:
        addresses.append(primary)
    if secondary:
        addresses.append(secondary)
    return addresses or ["0x0000"]


def fetch_balances(addresses: List[str]) -> Dict[str, float]:
    """Fetch balances for the provided addresses.

    When Web3 and a valid ``RPC_URL`` are available, query the network
    for actual balances.  Otherwise generate random floats for each
    address.  Any RPC errors are logged and the corresponding address
    receives a fallback random balance.
    """
    rpc_url = os.getenv("RPC_URL")
    balances: Dict[str, float] = {}
    if Web3 and rpc_url:
        try:
            w3 = Web3(Web3.HTTPProvider(rpc_url))  # type: ignore
            for addr in addresses:
                try:
                    bal_wei = w3.eth.get_balance(addr)
                    bal_eth = w3.from_wei(bal_wei, "ether")
                    balances[addr] = float(bal_eth)
                except Exception as e:
                    insert_log(
                        "agent_logs",
                        {
                            "agent": AGENT_NAME,
                            "event": "wallet_fetch_error",
                            "details": {"address": addr, "error": str(e)},
                        },
                    )
                    balances[addr] = round(random.uniform(0.0, 1.0), 4)
            return balances
        except Exception as e:
            insert_log(
                "agent_logs",
                {
                    "agent": AGENT_NAME,
                    "event": "rpc_connection_error",
                    "details": str(e),
                },
            )
    return {addr: round(random.uniform(0.0, 1.0), 4) for addr in addresses}


def process_directive(directive: Dict) -> None:
    """Handle a directive targeted at the WalletMonitor.

    Currently supports ``CHECK_BALANCES``.  Unknown directives are
    logged.
    """
    directive_id = directive["id"]
    command = directive["command"]
    addresses = get_wallet_addresses()
    if command == "CHECK_BALANCES":
        balances = fetch_balances(addresses)
        for addr, bal in balances.items():
            insert_log(
                "wallet_balances",
                {"agent": AGENT_NAME, "address": addr, "balance": bal},
            )
        insert_log(
            "agent_logs",
            {
                "agent": AGENT_NAME,
                "event": "balances_fetched",
                "details": balances,
            },
        )
    else:
        insert_log(
            "agent_logs",
            {"agent": AGENT_NAME, "event": "unknown_directive", "details": command},
        )
    mark_directive_complete(directive_id)


def run_worker() -> None:
    """Main loop for the WalletMonitor.

    Polls for directives and falls back to periodic heartbeats.
    The heartbeat interval can be configured via the
    ``WALLET_MONITOR_INTERVAL`` environment variable (in seconds),
    defaulting to once per day.
    """
    interval_str = os.getenv("WALLET_MONITOR_INTERVAL", "86400")
    try:
        interval = int(interval_str)
    except ValueError:
        interval = 86400
    while True:
        directives = fetch_pending_directives(AGENT_NAME)
        if directives:
            process_directive(directives[0])
        else:
            addresses = get_wallet_addresses()
            balances = fetch_balances(addresses)
            for addr, bal in balances.items():
                insert_log(
                    "wallet_balances",
                    {"agent": AGENT_NAME, "address": addr, "balance": bal},
                )
            insert_log(
                "agent_logs",
                {
                    "agent": AGENT_NAME,
                    "event": "heartbeat",
                    "details": "logged wallet balances",
                },
            )
            time.sleep(interval)


if __name__ == "__main__":
    run_worker()
