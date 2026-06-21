# Gitea Runbook

## Purpose
Private version control for lab configuration and notes.

## Start
```bash
docker compose up -d gitea
```

## Backup
```bash
./scripts/backup-gitea.sh
```

## Restore
1. Stop Gitea: `docker compose stop gitea`
2. Extract backup over the Gitea data volume.
3. Start Gitea: `docker compose start gitea`

## Common Issues
- If the web UI is unreachable, verify the container is on the expected Docker network and accessible via VPN or reverse proxy.
