-- 🧠 RAG Memory Schema for Infinity X One
-- Ensure pgvector is enabled
create extension if not exists vector;

-- 🧬 Main Memory Table
create table if not exists rosetta_memory (
  id uuid primary key default gen_random_uuid(),
  agent_id text not null,
  user_input text,
  gpt_response text,
  embedding vector(1536),
  timestamp timestamptz default now()
);

-- 📊 Query Logs for RAG Retrievals
create table if not exists rag_query_logs (
  id uuid primary key default gen_random_uuid(),
  query_text text,
  matching_chunks text[],
  agent_id text,
  triggered_by text,
  timestamp timestamptz default now()
);
