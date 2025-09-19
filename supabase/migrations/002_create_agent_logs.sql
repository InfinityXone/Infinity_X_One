create table if not exists agent_logs (
  id uuid primary key default uuid_generate_v4(),
  agent_name text not null,
  action text not null,
  status text not null,
  details jsonb,
  timestamp timestamptz default now()
);
