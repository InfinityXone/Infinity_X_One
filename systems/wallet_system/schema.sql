create table if not exists wallet_vault (
  id bigint generated always as identity primary key,
  agent text not null,
  wallet text not null,
  created_at timestamp default now()
);
