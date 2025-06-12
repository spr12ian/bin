#!/bin/bash
set -euo pipefail

# === AUTO-DETECT WINDOWS USERNAME ===
WIN_USER=$(ls /mnt/c/Users | grep -v "Public" | head -n 1)
echo "Detected Windows user: $WIN_USER"

# === CONFIGURATION ===
WSL_HOME="/home/$USER"
DEST_DIR="/mnt/c/Users/$WIN_USER/My Drive/WSL Backup"
KEEP_LATEST=5

EXCLUDES=(
  ".cache"
  "Downloads"
  "node_modules"
  ".npm"
  ".local/share/Trash"
)

# === BUILD EXCLUDE OPTIONS ===
TAR_EXCLUDES=()
for exclude in "${EXCLUDES[@]}"; do
    TAR_EXCLUDES+=(--exclude="$WSL_HOME/$exclude")
done

# === CREATE BACKUP ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="wsl_home_${TIMESTAMP}.tar.gz"

echo "Backing up $WSL_HOME to $DEST_DIR/$BACKUP_NAME"
mkdir -p "$DEST_DIR"

tar -czvf "$DEST_DIR/$BACKUP_NAME" "${TAR_EXCLUDES[@]}" -C "$WSL_HOME" .

echo "Backup complete: $DEST_DIR/$BACKUP_NAME"

# === KEEP ONLY LATEST N BACKUPS ===
echo "Pruning old backups, keeping latest $KEEP_LATEST..."
cd "$DEST_DIR"
ls -1t wsl_home_*.tar.gz | tail -n +$((KEEP_LATEST + 1)) | xargs -r rm -f

echo "Done."
