# Anthony's HomeLab

A self-hosted infrastructure lab for learning Linux, Docker, networking, cloud fundamentals, and DevOps practices.

## Motivation

My background is in live production and AV-over-IP systems, where reliability, signal flow, and network troubleshooting matter. This lab is how I am translating that production-grade mindset into modern infrastructure skills: Linux administration, containerization, version control, monitoring, and eventually cloud and Kubernetes.

## Architecture

```
[Internet]
   |
[Tailscale Mesh VPN]
   |
[Proxmox VE Host]
   |-- LVM-Thin datastore
   |-- VMs / LXC containers
   |-- Docker host
       |-- Gitea (version control)
       |-- Portainer (container management)
       |-- Uptime Kuma (service monitoring)
```

## Hardware

- **Host:** Recycled workstation/server
- **Storage:** External LVM-Thin datastore
- **Hypervisor:** Proxmox VE
- **Remote access:** Tailscale mesh VPN

## Services

| Service | Purpose | Tech |
|---------|---------|------|
| Gitea | Private version control for configs and notes | Docker |
| Portainer | Web UI for managing containers | Docker Compose |
| Uptime Kuma | Service availability monitoring and alerting | Docker Compose |

## Repository Structure

```
.
├── docker-compose.yml      # Core services stack
├── ansible/                # Server provisioning playbooks
├── scripts/                # Python/Bash automation scripts
├── docs/                   # Runbooks and notes
├── monitoring/             # Prometheus/Grafana configs
└── README.md               # This file
```

## What I Have Learned

- Deploying and managing Proxmox VE hypervisor and LVM-Thin storage.
- Container orchestration with Docker Compose.
- Secure cross-platform remote access using Tailscale.
- Version-controlling infrastructure configs with Gitea/Git.
- Service monitoring fundamentals with Uptime Kuma.
- Linux networking, systemd services, and firewall basics.

## Future Roadmap

- [ ] Add Prometheus + Grafana monitoring stack.
- [ ] Introduce Terraform for cloud resource provisioning.
- [ ] Build CI/CD pipeline with GitHub Actions.
- [ ] Deploy a small app to a local Kubernetes (k3s) cluster.
- [ ] Document incident response runbooks.

## Contact

- LinkedIn: *(to be added)*
- Résumé: *(to be added)*
