#!/usr/bin/env bash
set -euo pipefail

# Make a destination folder in your Linux home (fast)
mkdir -p ~/GoogleDrive

sudo -v
curl -fsSL https://rclone.org/install.sh | sudo bash
rclone version

# rclone config
# Choose n (New remote)
# Name it gdrive
# Choose 22 (Google Drive)

# rclone listremotes

# # List top-level folders in your Drive
# rclone lsd gdrive:

# # Optional: check Drive usage/quota
# rclone about gdrive:

# # Copy an entire folder from Drive to your WSL folder
# rclone copy "gdrive:Path/To/Folder" ~/GoogleDrive/Folder --progress --transfers 8 --checkers 8

# rclone sync "gdrive:Path/To/Folder" ~/GoogleDrive/Folder --dry-run --progress

# # Sync a folder from Drive to your WSL folder (deletes files in dest that are not in source)
# rclone sync "gdrive:Path/To/Folder" ~/GoogleDrive/Folder --progress --transfers 8 --checkers 8
