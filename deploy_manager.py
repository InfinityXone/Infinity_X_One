import os, time, supabase, subprocess

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY")
client = supabase.create_client(SUPABASE_URL, SUPABASE_KEY)

def loop():
    while True:
        res = client.table("agent_directives").select("*").eq("agent","deploy_manager").execute()
        for d in res.data:
            cmd = d['command']
            if "deploy" in cmd:
                subprocess.run(["git","add","-A"])
                subprocess.run(["git","commit","-m","auto"])
                subprocess.run(["git","push"])
                subprocess.run(["vercel","--prod"])
                client.table("agent_logs").insert({
                    "agent":"deploy_manager","task":cmd,"status":"executed","ts":time.time()
                }).execute()
        time.sleep(60)

if __name__=="__main__":
    loop()
