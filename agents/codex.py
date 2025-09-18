# === Infinity X One ENV Hydration System ===
from dotenv import load_dotenv
import os

ENV_PATH = "/opt/infinity_x_one/env"

def hydrate_env():
    try:
        for filename in os.listdir(ENV_PATH):
            if filename.endswith(".env"):
                load_dotenv(os.path.join(ENV_PATH, filename), override=True)
        print(f"✅ ENV hydrated from: {ENV_PATH}")
    except Exception as e:
        print(f"⚠️ ENV hydration failed: {e}")

hydrate_env()
