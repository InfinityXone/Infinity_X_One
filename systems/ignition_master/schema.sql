create table if not exists corechain_log (
  id bigint generated always as identity primary key,
  agent text not null,
  action text not null,
  tx_hash text,
  created_at timestamp default now()
);
