#!/usr/bin/env bash
set -euo pipefail

# Run on a fresh Ubuntu Droplet after SSH login.
# This installs Docker, starts the service, and prepares an app directory.

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

sudo mkdir -p /opt/module10-capstone-portal
sudo chown "$USER":"$USER" /opt/module10-capstone-portal

echo "Docker installed. Copy deployment files to /opt/module10-capstone-portal, then run docker compose up -d."
