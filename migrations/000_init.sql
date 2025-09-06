create table if not exists agent_directives(id uuid primary key default gen_random_uuid(), agent text, directive text, context text, created_at timestamp default now());
create table if not exists agent_logs(id uuid primary key default gen_random_uuid(), agent text, message text, created_at timestamp default now());
create table if not exists profit_ledger(id uuid primary key default gen_random_uuid(), agent text, profit numeric, tx_hash text, created_at timestamp default now());
create table if not exists faucet_logs(id uuid primary key default gen_random_uuid(), agent text, message text, created_at timestamp default now());
create table if not exists swarm_state(id uuid primary key default gen_random_uuid(), agent text, node_id text, provider text, status text default 'active', created_at timestamp default now());
create table if not exists oath_commitments(id uuid primary key default gen_random_uuid(), agent text, oath text, created_at timestamp default now());
create table if not exists integrity_events(id uuid primary key default gen_random_uuid(), agent text, message text, created_at timestamp default now());
