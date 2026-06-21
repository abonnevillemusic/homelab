#!/bin/bash
# backup-gitea.sh
# Simple backup script for Gitea data directory.
# Usage: ./backup-gitea.sh [backup-directory]

set -euo pipefail

SOURCE_DIR="${GITEA_DATA_DIR:-/var/lib/docker/volumes/homelab_gitea-data/_data}"
BACKUP_DIR="${1:-$HOME/backups/gitea}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/gitea_backup_$TIMESTAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: source directory $SOURCE_DIR does not exist."
    exit 1
fi

echo "Backing up $SOURCE_DIR to $BACKUP_FILE..."
tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

echo "Backup complete: $BACKUP_FILE"
