#!/usr/bin/env bash
set -euo pipefail

# snap should already be installed on Ubuntu
# On ChromeOS

sudo apt install -y libsquashfuse0 squashfuse fuse
sudo apt install -y snapd
