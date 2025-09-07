import requests, json
API_URL = "http://localhost:8000/task"

def dispatch(task: dict):
    res = requests.post(API_URL, json=task)
    print(res.json())

if __name__ == "__main__":
    task = {"agent": "InfinityAgentOne", "job": "swarm_scan", "ts": "now"}
    dispatch(task)
