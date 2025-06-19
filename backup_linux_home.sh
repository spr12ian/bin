#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="/mnt/chromeos/MyFiles/GoogleDrive/My Drive/Linux Backup"
mkdir -p "$DEST_DIR"

# Optional: exclude large folders
tar -czvf "$DEST_DIR/linux_home_backup_${USER}_$(date +%Y%m%d_%H%M%S).tar.gz" \
    --exclude="$HOME/.cache" \
    --exclude="$HOME/Downloads" \
    -C "$HOME" .

echo "Linux backup complete."
