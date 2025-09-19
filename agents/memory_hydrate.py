#!/opt/infinity_x_one/agents/venv/bin/python
import os, psycopg2, json, datetime

def hydrate_memory(agent_name="Infinity Agent One"):
    conn_url = os.getenv("SUPABASE_CONN")
    if not conn_url:
        print("❌ No SUPABASE_CONN set.")
        return {}

    conn = psycopg2.connect(conn_url)
    cur = conn.cursor()

    # Pull Rosetta doctrine + memory
    cur.execute("""
        select memory_type, content
        from rossetta_memory
        where agent_name = %s or agent_name = 'global'
        order by created_at desc
    """, (agent_name,))
    memory = [{"type": m[0], "content": m[1]} for m in cur.fetchall()]

    # Pull recent logs
    cur.execute("""
        select message, role
        from agent_logs
        where agent_name = %s
        order by created_at desc
        limit 10
    """, (agent_name,))
    logs = [{"role": l[1], "message": l[0]} for l in cur.fetchall()]

    hydrated = {
        "agent": agent_name,
        "manifesto": memory,
        "recent_logs": logs
    }

    # Insert confirmation log
    cur.execute("""
        insert into agent_logs (agent_name, message, role)
        values (%s, %s, %s)
    """, (agent_name, f"✅ Hydrated memory at {datetime.datetime.utcnow()}", "system"))
    conn.commit()

    conn.close()

    print("✅ Hydrated memory for", agent_name)
    print(json.dumps(hydrated, indent=2))
    return hydrated

if __name__ == "__main__":
    hydrate_memory(os.getenv("DEFAULT_AGENT_NAME", "Infinity Agent One"))
