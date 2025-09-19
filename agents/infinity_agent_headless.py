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
