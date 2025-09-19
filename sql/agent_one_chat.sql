-- Infinity Agent One Chat Schema

create table if not exists agent_commands (
    id uuid primary key default gen_random_uuid(),
    agent text not null,
    command text not null,
    created_at timestamptz default now()
);

create table if not exists agent_logs (
    id uuid primary key default gen_random_uuid(),
    agent text not null,
    reply text not null,
    created_at timestamptz default now()
);

create index if not exists idx_agent_logs_created_at on agent_logs (created_at desc);
create index if not exists idx_agent_commands_created_at on agent_commands (created_at desc);

alter table agent_commands enable row level security;
alter table agent_logs enable row level security;
