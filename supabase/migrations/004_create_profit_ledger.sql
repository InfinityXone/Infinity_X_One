create table if not exists profit_ledger (
  id uuid primary key default uuid_generate_v4(),
  wallet text not null,
  faucet text,
  amount numeric not null,
  currency text not null,
  tx_hash text,
  timestamp timestamptz default now()
);
