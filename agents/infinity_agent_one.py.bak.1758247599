import uvicorn, socket, logging

logging.basicConfig(
    filename="/opt/infinity_x_one/logs/agent_one.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

def find_free_port(preferred_ports=[8000, 8001, 8101]):
    for port in preferred_ports:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            try:
                s.bind(("0.0.0.0", port))
                s.close()
                logging.info(f"✅ Selected free port: {port}")
                return port
            except OSError:
                logging.warning(f"⚠️ Port {port} busy, trying next...")
                continue
    raise RuntimeError("❌ No free ports found in preferred list")

if __name__ == "__main__":
    port = find_free_port()
    logging.info(f"🚀 Infinity Agent One starting on port {port}")
    uvicorn.run("agent_one_app:app", host="0.0.0.0", port=port)
