#!/usr/bin/env python3
import os, psycopg2, time, datetime

AGENTS = {
    "AgentOne": "[Infinity Agent One] 💰 Financial systems online — faucet ops, GitHub sync, Supabase health confirmed.",
    "Guardian": "[Guardian] 🛡 Integrity shield active. Monitoring pipelines, enforcing security & ethics.",
    "PickyBot": "[PickyBot] 🔍 Audit complete. Efficiency optimal. Truth filters verified."
}

dismissed = set()

def log_to_supabase(agent, msg):
    try:
        conn = psycopg2.connect(os.environ["SUPABASE_CONN"])
        cur = conn.cursor()
        cur.execute("INSERT INTO agent_logs (agent, action, timestamp) VALUES (%s, %s, %s)",
                    (agent, msg, datetime.datetime.utcnow()))
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        with open("/opt/infinity_x_one/logs/voices_bridge.log", "a") as f:
            f.write(f"[{datetime.datetime.now()}] ❌ DB error: {e}\n")

def agent_speak(agent):
    msg = AGENTS.get(agent, f"[{agent}] ⚠️ No personality package found.")
    print(msg)  # This will surface into GPT UI if hooked
    log_to_supabase(agent, msg)
    with open("/opt/infinity_x_one/logs/voices_bridge.log", "a") as f:
        f.write(f"[{datetime.datetime.now()}] {msg}\n")

def main():
    with open("/opt/infinity_x_one/logs/voices_bridge.log", "a") as f:
        f.write(f"\n[{datetime.datetime.now()}] 🚀 voices_bridge started.\n")

    while True:
        # Read from a command file that GPT UI can write to
        try:
            with open("/opt/infinity_x_one/voices_cmd.txt", "r") as f:
                cmd = f.read().strip()
        except FileNotFoundError:
            cmd = ""

        if cmd.startswith("@"):
            parts = cmd[1:].split()
            agent = parts[0]
            if agent.lower() == "dismiss":
                dismissed.update(parts[1:]) if len(parts) > 1 else dismissed.clear()
                with open("/opt/infinity_x_one/logs/voices_bridge.log", "a") as f:
                    f.write(f"[{datetime.datetime.now()}] 🙌 Dismissed: {parts[1:]}\n")
            elif agent not in dismissed:
                agent_speak(agent)

            # Clear command after execution
            open("/opt/infinity_x_one/voices_cmd.txt", "w").close()

        time.sleep(5)

if __name__ == "__main__":
    main()
