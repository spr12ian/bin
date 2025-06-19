#!/usr/bin/env bash
set -euo pipefail

# === CONFIGURATION ===
# === AUTO-DETECT WINDOWS USERNAME ===
WIN_USER=$(ls /mnt/c/Users | grep -v "Public" | head -n 1)
echo "Detected Windows user: $WIN_USER"

DEST_DIR="/mnt/c/Users/$WIN_USER/My Drive/WSL Backup"
RESTORE_DIR="/home/$USER"

# === FIND LATEST BACKUP ===
LATEST_BACKUP=$(ls -1t "$DEST_DIR"/wsl_home_*.tar.gz | head -n 1)

if [[ -z "$LATEST_BACKUP" ]]; then
    echo "No backup files found in $DEST_DIR"
    exit 1
fi

echo "Latest backup found: $LATEST_BACKUP"

# === CONFIRM RESTORE ===
read -p "Restore to $RESTORE_DIR? (existing files may be overwritten) [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Restore cancelled."
    exit 0
fi

# === RUN RESTORE ===
tar -xzvf "$LATEST_BACKUP" -C "$RESTORE_DIR"

echo "Restore complete."

