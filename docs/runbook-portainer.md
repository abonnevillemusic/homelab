# Portainer Runbook

## Purpose
Web UI for managing Docker containers and volumes.

## Start
```bash
docker compose up -d portainer
```

## Access
Portainer is not exposed to the public internet. Access it via the internal Docker network or through a secure reverse proxy/VPN.

## Common Issues
- If containers do not appear, verify the Docker socket mount is correct.
- Portainer requires access to `/var/run/docker.sock`.
