create table if not exists swarm_state (
  id uuid primary key default uuid_generate_v4(),
  total_agents int not null,
  active_agents int not null,
  revenue_usd numeric,
  heartbeat timestamptz default now()
);
