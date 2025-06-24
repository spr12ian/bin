#!/usr/bin/env bash
set -euo pipefail

install_snap() {
  local snap_name="$1"
  local classic_flag="${2:-}"  # Default to empty string if not passed

  if snap list "$snap_name" &> /dev/null; then
    echo "$snap_name is already installed. Refreshing..."
    sudo snap refresh "$snap_name"
  else
    if [[ "$classic_flag" == "--classic" ]]; then
      echo "Installing $snap_name with classic confinement..."
      sudo snap install "$snap_name" --classic
    else
      echo "Installing $snap_name..."
      sudo snap install "$snap_name"
    fi
  fi
}

# Install snaps with appropriate confinement
# install_snap code --classic
install_snap go --classic
install_snap hugo
install_snap node --classic
install_snap sqlitebrowser

echo "Installation/Refresh complete."
