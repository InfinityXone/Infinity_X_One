# 🌐 Modified by GPT @ 2025-09-17 23:55:07
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
#!/usr/bin/env python3
"""
Infinity Agent One - Headless Browser Agent
-------------------------------------------
API-driven headless agent for monitoring + executing GPT instructions.
"""

from flask import Flask, request, jsonify
from playwright.sync_api import sync_playwright
import os

app = Flask(__name__)

@app.route("/browse", methods=["POST"])
def browse():
    data = request.json
    url = data.get("url", "https://example.com")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(url)
        title = page.title()
        content = page.content()
        browser.close()

    return jsonify({
        "url": url,
        "title": title,
        "content_snippet": content[:500]  # first 500 chars only
    })

if __name__ == "__main__":
    port = int(os.getenv("AGENT_PORT", 8001))
    print(f"🚀 Infinity Agent One Headless Browser running on port {port}")
    app.run(host="0.0.0.0", port=port)
