"""
Simple deployment portal for Module 10.

This uses Python's standard library so the deployment workflow is visible
before adding a full framework such as FastAPI.
"""

from __future__ import annotations

import html
import json
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote


APP_DIR = Path(__file__).resolve().parent
ARTIFACT_DIR = APP_DIR / "published_artifacts"
PORT = int(os.getenv("PORT", "8000"))


class CapstonePortalHandler(SimpleHTTPRequestHandler):
    """Serve a small dashboard plus static artifact files."""

    def do_GET(self) -> None:  # noqa: N802 - stdlib handler method name
        path = unquote(self.path.split("?", 1)[0])
        if path in {"/", "/index.html"}:
            self.render_index()
            return
        if path == "/health":
            self.write_json({"status": "ok", "service": "module10-capstone-portal"})
            return
        if path.startswith("/artifacts/"):
            filename = path.replace("/artifacts/", "", 1)
            self.serve_artifact(filename)
            return
        self.send_error(404, "Not found")

    def render_index(self) -> None:
        manifest = self.load_manifest()
        rows = []
        for item in manifest.get("copied", []):
            filename = html.escape(item["filename"])
            label = html.escape(item["label"])
            size = item.get("size_bytes", 0)
            rows.append(
                f"<tr><td>{label}</td><td><a href='/artifacts/{filename}'>{filename}</a></td><td>{size}</td></tr>"
            )

        body = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Central Bank Database Programming Capstone Portal</title>
  <style>
    body {{ font-family: Arial, sans-serif; margin: 28px; color: #172033; line-height: 1.45; }}
    h1, h2 {{ color: #17324d; }}
    .grid {{ display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; margin: 18px 0; }}
    .card {{ border: 1px solid #cbd5e1; border-radius: 6px; padding: 12px; background: #f8fafc; }}
    .metric {{ font-size: 26px; font-weight: 700; }}
    table {{ border-collapse: collapse; width: 100%; margin-top: 12px; font-size: 14px; }}
    th, td {{ border: 1px solid #cbd5e1; padding: 8px; text-align: left; }}
    th {{ background: #e8eef7; }}
    a {{ color: #0f766e; }}
  </style>
</head>
<body>
  <h1>Central Bank Database Programming Capstone Portal</h1>
  <p>This portal packages the reporting, monitoring, security, compliance, KPI, and ROI evidence produced during the programme.</p>
  <div class="grid">
    <div class="card"><strong>Artifacts Published</strong><div class="metric">{manifest.get("copied_count", 0)}</div></div>
    <div class="card"><strong>Missing Artifacts</strong><div class="metric">{manifest.get("missing_count", 0)}</div></div>
    <div class="card"><strong>Deployment Target</strong><div>{html.escape(manifest.get("deployment_target", "DigitalOcean"))}</div></div>
  </div>
  <h2>Published Evidence</h2>
  <table>
    <thead><tr><th>Evidence</th><th>File</th><th>Size Bytes</th></tr></thead>
    <tbody>{''.join(rows)}</tbody>
  </table>
  <h2>Operations</h2>
  <p>Health endpoint: <a href="/health">/health</a></p>
</body>
</html>"""
        self.write_bytes(body.encode("utf-8"), "text/html; charset=utf-8")

    def load_manifest(self) -> dict:
        path = ARTIFACT_DIR / "artifact_manifest.json"
        if not path.exists():
            return {
                "copied_count": 0,
                "missing_count": 0,
                "copied": [],
                "deployment_target": "DigitalOcean",
            }
        return json.loads(path.read_text(encoding="utf-8"))

    def serve_artifact(self, filename: str) -> None:
        safe_name = Path(filename).name
        path = ARTIFACT_DIR / safe_name
        if not path.exists() or not path.is_file():
            self.send_error(404, "Artifact not found")
            return

        content_type = "application/json" if path.suffix == ".json" else "text/plain"
        if path.suffix == ".html":
            content_type = "text/html; charset=utf-8"
        self.write_bytes(path.read_bytes(), content_type)

    def write_json(self, payload: dict) -> None:
        self.write_bytes(json.dumps(payload, indent=2).encode("utf-8"), "application/json")

    def write_bytes(self, body: bytes, content_type: str) -> None:
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main() -> None:
    server = ThreadingHTTPServer(("0.0.0.0", PORT), CapstonePortalHandler)
    print(f"Capstone portal running on http://0.0.0.0:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()
