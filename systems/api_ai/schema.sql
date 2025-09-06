create table if not exists tasks (
  id bigint generated always as identity primary key,
  agent text not null,
  task text not null,
  status text default 'pending',
  created_at timestamp default now()
);
