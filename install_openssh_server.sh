#!/usr/bin/env bash
set -euo pipefail

# Check if openssh-server is installed
if dpkg -l | grep -q openssh-server; then
    echo "openssh-server is installed."
    exit
fi

install_apt_package openssh-server

sudo systemctl daemon-reload

# Check the server is running
sudo systemctl --no-pager status ssh

