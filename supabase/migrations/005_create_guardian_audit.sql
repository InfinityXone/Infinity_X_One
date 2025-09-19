create table if not exists guardian_audit (
  id uuid primary key default uuid_generate_v4(),
  validator text not null,
  subject text not null,
  decision text not null,
  notes text,
  timestamp timestamptz default now()
);
