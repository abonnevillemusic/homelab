#!/bin/bash
# restore-proxmox-config.sh
# Restore Proxmox VE configuration files from a backup created by backup-proxmox-config.sh.
# Run as root on the Proxmox VE host.
# Usage: bash restore-proxmox-config.sh /path/to/backup-dir

set -euo pipefail

BACKUP_DIR="${1:-}"

if [ -z "$BACKUP_DIR" ]; then
    echo "Usage: $0 /path/to/backup-dir"
    echo "Available backups:"
    ls -1d /root/proxmox-config-backups/* 2>/dev/null || echo "  none found"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: backup directory not found: $BACKUP_DIR"
    exit 1
fi

if [ ! -f "$BACKUP_DIR/MANIFEST.txt" ]; then
    echo "Warning: MANIFEST.txt missing. Are you sure this is a valid backup?"
    read -p "Continue? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "Restoring Proxmox config from: $BACKUP_DIR"
echo "Current hostname: $(hostname)"
echo "Proxmox version: $(pveversion 2>/dev/null || echo 'unknown')"
echo ""
read -p "Are you sure? This will overwrite current config files. [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# APT repositories
if [ -d "$BACKUP_DIR/sources.list.d" ]; then
    echo "Restoring APT sources..."
    cp -r "$BACKUP_DIR/sources.list.d/"* /etc/apt/sources.list.d/ 2>/dev/null || true
fi
if [ -f "$BACKUP_DIR/sources.list" ]; then
    cp "$BACKUP_DIR/sources.list" /etc/apt/sources.list
fi

# Network config
if [ -d "$BACKUP_DIR/network" ]; then
    echo "Restoring network configuration..."
    cp -r "$BACKUP_DIR/network/"* /etc/network/ 2>/dev/null || true
fi
if [ -f "$BACKUP_DIR/hosts" ]; then
    cp "$BACKUP_DIR/hosts" /etc/hosts
fi
if [ -f "$BACKUP_DIR/hostname" ]; then
    cp "$BACKUP_DIR/hostname" /etc/hostname
fi

# SSH config
if [ -d "$BACKUP_DIR/ssh" ]; then
    echo "Restoring SSH configuration and keys..."
    cp -r "$BACKUP_DIR/ssh/"* /etc/ssh/ 2>/dev/null || true
fi

# Systemd logind config
if [ -f "$BACKUP_DIR/logind.conf" ]; then
    echo "Restoring systemd logind config..."
    cp "$BACKUP_DIR/logind.conf" /etc/systemd/logind.conf
    systemctl restart systemd-logind || true
fi

# Proxmox /etc/pve
if [ -d "$BACKUP_DIR/pve" ]; then
    echo "Restoring Proxmox /etc/pve config..."
    cp -r "$BACKUP_DIR/pve/"* /etc/pve/ 2>/dev/null || true
fi

# Cron jobs
if [ -d "$BACKUP_DIR/cron.d" ]; then
    cp -r "$BACKUP_DIR/cron.d/"* /etc/cron.d/ 2>/dev/null || true
fi
if [ -d "$BACKUP_DIR/cron.daily" ]; then
    cp -r "$BACKUP_DIR/cron.daily/"* /etc/cron.daily/ 2>/dev/null || true
fi

# Root scripts
if [ -d "$BACKUP_DIR/root-scripts" ]; then
    mkdir -p /root/scripts
    cp -r "$BACKUP_DIR/root-scripts/"* /root/scripts/ 2>/dev/null || true
fi

echo ""
echo "Restore complete."
echo "Next steps:"
echo "  1. Review restored files."
echo "  2. Run: apt update && apt upgrade -y"
echo "  3. Reboot if network config or kernel was changed."
echo "  4. Re-import package list if desired: dpkg --set-selections < $BACKUP_DIR/dpkg-packages.list"
