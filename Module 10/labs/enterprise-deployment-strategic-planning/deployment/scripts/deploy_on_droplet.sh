#!/usr/bin/env bash
set -euo pipefail

# Run from /opt/module10-capstone-portal on the Droplet after copying files.

docker compose pull || true
docker compose up -d --build
docker compose ps
curl -fsS http://127.0.0.1:8000/health
