#!/bin/bash
# backup-proxmox-config.sh
# Backs up Proxmox VE configuration files that are commonly modified after a fresh install.
# This makes re-installs or rebuilds much faster.
# Run as root on the Proxmox VE host.

set -euo pipefail

BACKUP_DIR="/root/proxmox-config-backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backing up Proxmox config to $BACKUP_DIR..."

# APT repositories
cp -r /etc/apt/sources.list "$BACKUP_DIR/sources.list" 2>/dev/null || true
cp -r /etc/apt/sources.list.d "$BACKUP_DIR/sources.list.d" 2>/dev/null || true

# Network configuration
cp -r /etc/network "$BACKUP_DIR/network" 2>/dev/null || true
cp /etc/hosts "$BACKUP_DIR/hosts" 2>/dev/null || true

# Hostname
cp /etc/hostname "$BACKUP_DIR/hostname" 2>/dev/null || true

# SSH server keys and config
cp -r /etc/ssh "$BACKUP_DIR/ssh" 2>/dev/null || true

# Systemd logind config (includes HandleLidSwitch)
cp -r /etc/systemd/logind.conf "$BACKUP_DIR/logind.conf" 2>/dev/null || true

# Proxmox datacenter and node configs
cp -r /etc/pve "$BACKUP_DIR/pve" 2>/dev/null || true

# Installed packages list
dpkg -l > "$BACKUP_DIR/dpkg-packages.list"

# Custom scripts or cron jobs
cp -r /etc/cron.d "$BACKUP_DIR/cron.d" 2>/dev/null || true
cp -r /etc/cron.daily "$BACKUP_DIR/cron.daily" 2>/dev/null || true
cp -r /var/spool/cron "$BACKUP_DIR/cron-users" 2>/dev/null || true

# Any custom files in /root
if [ -d /root/scripts ]; then
    cp -r /root/scripts "$BACKUP_DIR/root-scripts" 2>/dev/null || true
fi

# Create a manifest
{
    echo "Backup created: $(date)"
    echo "Hostname: $(hostname)"
    echo "Proxmox version: $(pveversion 2>/dev/null || echo 'unknown')"
    echo "---"
    echo "Files backed up:"
    find "$BACKUP_DIR" -type f | sed "s|^$BACKUP_DIR/||"
} > "$BACKUP_DIR/MANIFEST.txt"

echo "Backup complete: $BACKUP_DIR"
echo "Total size:"
du -sh "$BACKUP_DIR"

echo ""
echo "To restore after a fresh install, copy the files back and run:"
echo "  apt update && apt upgrade -y"
