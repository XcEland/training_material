# Module 10 Deployment: DigitalOcean Capstone Portal

This folder contains a small deployable portal for the final Module 10 capstone. The portal serves the evidence generated across the course:

- Module 6 WEO reporting metrics and run log
- Module 8 monitoring dashboard and snapshot
- Module 9 security assessment, compliance evidence, and KPI/ROI summary

The deployment target is a small Dockerized Python web portal that can run on either:

- a DigitalOcean Droplet using Docker Compose
- DigitalOcean App Platform using a container image from DigitalOcean Container Registry or Docker Hub

## 1. Prepare The Deployment Bundle

From the Module 10 lab folder:

```bash
cd "Module 10/labs/enterprise-deployment-strategic-planning"
python 03_prepare_deployment_bundle.py
```

This copies selected outputs into:

```text
deployment/published_artifacts/
```

The portal will read:

```text
deployment/published_artifacts/artifact_manifest.json
```

## 2. Run Locally Without Docker

```bash
cd deployment
python capstone_portal.py
```

Open:

```text
http://localhost:8000
```

Health check:

```text
http://localhost:8000/health
```

## 3. Run Locally With Docker Compose

```bash
cd deployment
docker compose up --build
```

Open:

```text
http://localhost:8000
```

Stop:

```bash
docker compose down
```

## 4. Option A: Deploy To A DigitalOcean Droplet

Use this path to practice server administration, SSH, firewall rules, Docker, logs, and rollback.

### Step 1: Create The Droplet

Recommended lab settings:

```text
Image: Ubuntu LTS or Docker 1-Click App
Size: Basic shared CPU
Authentication: SSH key
Firewall: allow SSH 22 and HTTP 80/8000 for training
```

For production, place the app behind a reverse proxy such as Nginx/Caddy and expose HTTPS only.

### Step 2: Bootstrap Docker

SSH into the Droplet:

```bash
ssh root@<droplet-ip>
```

Copy and run the bootstrap script:

```bash
bash droplet_bootstrap.sh
```

The script installs Docker Engine and the Docker Compose plugin on Ubuntu.

### Step 3: Copy Deployment Files

From your local machine:

```bash
scp -r deployment/* root@<droplet-ip>:/opt/module10-capstone-portal/
```

### Step 4: Start The App

On the Droplet:

```bash
cd /opt/module10-capstone-portal
bash scripts/deploy_on_droplet.sh
```

Open:

```text
http://<droplet-ip>:8000
```

### Step 5: Update / Rollback

Update:

```bash
scp -r deployment/* root@<droplet-ip>:/opt/module10-capstone-portal/
ssh root@<droplet-ip>
cd /opt/module10-capstone-portal
docker compose up -d --build
```

Rollback:

```bash
docker images
docker compose down
docker run -d --name module10-capstone-portal -p 8000:8000 <previous-image-id>
```

## 5. Option B: Deploy With DigitalOcean Container Registry And App Platform

Use this when students need a managed deployment workflow with less server administration.

### Step 1: Create Or Log Into Container Registry

Install and authenticate `doctl`, then log Docker into the registry:

```bash
doctl auth init
doctl registry create trainingcred-registry
doctl registry login
```

If a registry already exists, skip `doctl registry create`.

### Step 2: Build And Push The Image

From `deployment/`:

```bash
docker build -t registry.digitalocean.com/<registry-name>/module10-capstone-portal:latest .
docker push registry.digitalocean.com/<registry-name>/module10-capstone-portal:latest
```

### Step 3: Deploy On App Platform

You can deploy through the DigitalOcean Control Panel:

```text
Create -> App Platform -> Container Image -> DigitalOcean Container Registry
```

Select:

```text
Repository: module10-capstone-portal
Tag: latest
HTTP Port: 8000
Health Check: /health
```

Or use the included app spec:

```text
deployment/digitalocean/app-platform.yaml
```

Before using it, update the `repository` and registry details to match your DigitalOcean registry.

## 6. Docker Hub Alternative

If using Docker Hub instead of DigitalOcean Container Registry:

```bash
docker login
docker build -t xceland/module10-capstone-portal:latest .
docker push xceland/module10-capstone-portal:latest
```

Then select Docker Hub as the App Platform image source.

## 7. Production Controls

Before production rollout:

- use HTTPS and a domain name
- restrict access to internal users or VPN where needed
- do not package secrets into images
- use environment variables for runtime configuration
- retain deployment logs and rollback evidence
- scan images before release
- document change approval and deployment owner
- confirm data classification before publishing artifacts

## 8. Recommended Teaching Choice

Use both paths:

- Droplet deployment teaches infrastructure ownership and operational responsibility.
- App Platform deployment teaches managed release workflow and container registry practice.

Run locally first, then Docker Compose, then choose one DigitalOcean path for the capstone.
