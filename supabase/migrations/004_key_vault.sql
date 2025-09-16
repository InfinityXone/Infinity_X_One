create table if not exists key_vault (
  id uuid primary key default gen_random_uuid(),
  service text not null,
  key text not null,
  created_at timestamp with time zone default now(),
  rotated_by text default 'rotate_keys.ts'
);
create index if not exists idx_key_vault_service on key_vault(service);
