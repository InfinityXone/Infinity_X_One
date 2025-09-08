-- Enable pgvector extension
create extension if not exists vector;

-- Core memory table
create table if not exists rosetta_memory (
  id uuid primary key default gen_random_uuid(),
  session_id text not null,
  agent_name text not null,
  user_query text,
  ai_response text,
  context jsonb,
  created_at timestamp with time zone default timezone('utc', now())
);

-- Vector embedding table
create table if not exists vector_embeddings (
  id uuid primary key default gen_random_uuid(),
  memory_id uuid references rosetta_memory(id) on delete cascade,
  embedding vector(1536),
  created_at timestamp with time zone default timezone('utc', now())
);

-- Index for similarity search
create index if not exists idx_embedding_vector
on vector_embeddings
using ivfflat (embedding vector_cosine_ops)
with (lists = 100);

-- Optional context lookup table
create table if not exists context_tags (
  id uuid primary key default gen_random_uuid(),
  memory_id uuid references rosetta_memory(id) on delete cascade,
  tag text,
  weight float default 1.0,
  created_at timestamp with time zone default timezone('utc', now())
);
