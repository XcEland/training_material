"""
Serve the Module 8 monitoring dashboard in a browser.

Run:
    python3 08_web_dashboard_server.py

Open:
    http://localhost:8008/
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
DASHBOARD_MODULE_PATH = LAB_DIR / "06_monitoring_dashboard.py"


def load_dashboard_module():
    """Load 06_monitoring_dashboard.py even though its filename starts with a number."""
    spec = importlib.util.spec_from_file_location("module8_dashboard", DASHBOARD_MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    if spec.loader is None:
        raise RuntimeError("Could not load dashboard module.")
    spec.loader.exec_module(module)
    return module


def refresh_dashboard() -> dict:
    """Regenerate the dashboard files and return the current metrics."""
    dashboard = load_dashboard_module()
    return dashboard.render_dashboard(save_history=False)


class DashboardHandler(SimpleHTTPRequestHandler):
    """HTTP handler that refreshes metrics before serving dashboard files."""

    def send_text(self, content: str, content_type: str) -> None:
        encoded = content.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self) -> None:
        route = urlparse(self.path).path

        if route in ("/", "/monitoring_dashboard.html"):
            refresh_dashboard()
            html = (OUTPUT_DIR / "monitoring_dashboard.html").read_text(encoding="utf-8")
            self.send_text(html, "text/html; charset=utf-8")
            return

        if route == "/metrics.json":
            context = refresh_dashboard()
            self.send_text(json.dumps(context, indent=2), "application/json; charset=utf-8")
            return

        if route == "/monitoring_snapshot.json":
            refresh_dashboard()
            snapshot = (OUTPUT_DIR / "monitoring_snapshot.json").read_text(encoding="utf-8")
            self.send_text(snapshot, "application/json; charset=utf-8")
            return

        self.directory = str(OUTPUT_DIR)
        super().do_GET()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Serve the Module 8 monitoring dashboard.")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=8008)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    OUTPUT_DIR.mkdir(exist_ok=True)
    refresh_dashboard()

    server = ThreadingHTTPServer((args.host, args.port), DashboardHandler)
    print(f"Dashboard running at http://{args.host}:{args.port}/")
    print("JSON metrics endpoint: /metrics.json")
    server.serve_forever()


if __name__ == "__main__":
    main()
