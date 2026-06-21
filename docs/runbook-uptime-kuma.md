# Uptime Kuma Runbook

## Purpose
Monitor service availability and send alerts when services go down.

## Start
```bash
docker compose up -d uptime-kuma
```

## Configuration
1. Open the Uptime Kuma web UI.
2. Add monitors for each service (HTTP, TCP, Ping, etc.).
3. Configure notification channels (email, Slack, etc.).

## Common Issues
- If a monitor reports false positives, increase the retry count or heartbeat interval.
