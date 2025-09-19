create table if not exists orchestrator_logs (
  id uuid primary key default uuid_generate_v4(),
  filename text not null,
  commit_sha text not null,
  timestamp timestamptz default now()
);
