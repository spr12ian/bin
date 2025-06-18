#!/usr/bin/env bash
set -euo pipefail

sudo apt install -y python3 python3-pip



# Determine the Python 3 version
python_full_version=$(python3 --version 2>&1 | awk '{print $2}')
python_version="$(echo $python_full_version | cut -d. -f1-2)"
echo "Python version: $(echo $python_version | cut -d. -f1-2)"

# Check if `venv` is available
if ! command -v venv &> /dev/null; then
    # Install `python3-venv` package for Debian/Ubuntu
    if [[ $(grep -E '^ID=' /etc/os-release | cut -d= -f2) =~ ^(ubuntu|debian)$ ]]; then
        sudo apt install -y python${python_version}-venv
    # For other systems, you might need to use pip or other package managers
    else
        echo "Please install 'venv' using your system's package manager."
        exit 1
    fi
fi

python3 -m pip list --outdated
