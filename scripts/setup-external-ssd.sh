#!/bin/bash
# setup-external-ssd.sh
# Wipe, partition, format, and mount an external SSD for Proxmox VM/LXC/container storage.
# Run as root on the Proxmox VE host.
# WARNING: This will DESTROY all data on the target device.

set -euo pipefail

# EDIT THIS if your SSD is not /dev/sdc
DISK="${1:-/dev/sdc}"
MOUNTPOINT="${2:-/mnt/ssd-data}"
PARTITION="${DISK}1"

if [ ! -b "$DISK" ]; then
    echo "Error: $DISK is not a block device."
    echo "Usage: $0 [/dev/sdX] [/mnt/custom-mount]"
    exit 1
fi

echo "WARNING: This will WIPE all data on $DISK"
read -p "Are you sure? Type 'wipe' to continue: " confirm
if [ "$confirm" != "wipe" ]; then
    echo "Aborted."
    exit 1
fi

# Make sure the disk is not mounted
umount "${DISK}"* 2>/dev/null || true

# Wipe partition table and create a fresh GPT partition
wipefs -a "$DISK"
parted "$DISK" mklabel gpt
parted -a optimal "$DISK" mkpart primary ext4 0% 100%
parted "$DISK" print

# Format the new partition
mkfs.ext4 -F -L ssd-data "$PARTITION"

# Create mount point and mount
mkdir -p "$MOUNTPOINT"
mount "$PARTITION" "$MOUNTPOINT"

# Make persistent in /etc/fstab
if ! grep -q "$PARTITION" /etc/fstab; then
    echo "UUID=$(blkid -s UUID -o value "$PARTITION") $MOUNTPOINT ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Create subdirectories for Proxmox storage types
mkdir -p "$MOUNTPOINT/images"      # VM/LXC disk images
mkdir -p "$MOUNTPOINT/containers"  # LXC templates / rootfs
mkdir -p "$MOUNTPOINT/backups"     # VZDump backups
mkdir -p "$MOUNTPOINT/iso"         # ISO images
mkdir -p "$MOUNTPOINT/snippets"    # Proxmox snippets
mkdir -p "$MOUNTPOINT/docker"      # Docker data if running on host

# Set permissions for Proxmox
chown -R root:root "$MOUNTPOINT"
chmod -R 755 "$MOUNTPOINT"

echo ""
echo "SSD setup complete."
echo "  Device:     $DISK"
echo "  Partition:  $PARTITION"
echo "  Mount:      $MOUNTPOINT"
echo "  UUID:       $(blkid -s UUID -o value "$PARTITION")"
echo ""
echo "Next steps:"
echo "  1. Add as Proxmox Directory storage: Datacenter -> Storage -> Add -> Directory"
echo "     ID: ssd-data"
echo "     Directory: $MOUNTPOINT"
echo "     Content: Disk image, Container, VZDump backup, ISO image, Container template"
echo "  2. Move Docker data if needed: ln -s $MOUNTPOINT/docker /var/lib/docker"
echo "  3. Reboot and verify mount: df -h"
