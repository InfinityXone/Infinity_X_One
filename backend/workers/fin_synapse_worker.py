import time
from backend.supabase_utils import get_client
sb=get_client()
while True:
    sb.table("agent_logs").insert({"agent":"fin_synapse_worker","message":"heartbeat"}).execute()
    time.sleep(60)
