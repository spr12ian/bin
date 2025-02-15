#!/bin/bash

install_snap() {
  snap_name="$1"
  classic_flag="$2"  # Store the classic flag

  # Check if the snap package is listed in `snap list`
  if snap list "$snap_name" &> /dev/null; then
    echo "$snap_name is already installed. Refreshing..."
    sudo snap refresh "$snap_name"
  else
    if [[ "$classic_flag" == "--classic" ]]; then # Use [[ ]] for string comparison
      echo "Installing $snap_name with classic confinement..."
      sudo snap install "$snap_name" --classic
    else
      echo "Installing $snap_name..."
      sudo snap install "$snap_name"
    fi
  fi
}

# Install snaps with appropriate confinement
install_snap code --classic  # Code with classic
install_snap go --classic    # Go with classic
install_snap hugo            # Hugo (default confinement)
install_snap node --classic  # Node with classic
install_snap sqlitebrowser   # SQLite Browser (default confinement)

echo "Installation/Refresh complete."