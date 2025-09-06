create table if not exists key_vault (
  id bigint generated always as identity primary key,
  service text not null,
  key text not null,
  status text default 'active',
  created_at timestamp default now()
);
