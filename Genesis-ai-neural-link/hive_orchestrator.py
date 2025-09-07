import subprocess, time
def launch(name,path): print(f"[Hive] {name}"); subprocess.Popen(["python3",path])
if __name__=="__main__":
  for n,p in [("PromptWriter","backend/workers/promptwriter_worker.py"),
              ("Codex","backend/workers/codex_worker.py"),
              ("Guardian","backend/workers/guardian_worker.py"),
              ("PickyBot","backend/workers/pickybot_worker.py"),
              ("Echo","backend/workers/echo_worker.py"),
              ("Aria","backend/workers/aria_worker.py"),
              ("FinSynapse","backend/workers/fin_synapse_worker.py"),
              ("Infinity","backend/workers/infinity_worker.py"),
              ("Faucet","backend/workers/faucet_ignition.py"),
              ("KeyHarvester","backend/workers/api_key_harvester.py"),
              ("Atlas","backend/workers/compute_account_finder.py"),
              ("Optimizer","backend/workers/optimizer_worker.py"),
              ("ScraperX","backend/workers/scraperx_worker.py"),
              ("Strategy","backend/workers/strategy_launcher.py")]:
      launch(n,p); time.sleep(2)
  while True: time.sleep(3600)
