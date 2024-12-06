#!/bin/bash

# Check if openssh-server is installed
if dpkg -l | grep -q openssh-server; then
    echo "openssh-server is installed."
    exit
fi

sudo apt install -y openssh-server

# Check the server is running
sudo systemctl status ssh
