create table if not exists agent_tasks (
  id bigint generated always as identity primary key,
  agent text,
  job text,
  ts timestamp default now(),
  status text default 'pending'
);

create table if not exists agent_memory (
  id bigint generated always as identity primary key,
  agent text,
  memory jsonb,
  ts timestamp default now()
);
