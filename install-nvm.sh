#!/bin/bash
set -euo pipefail

# Check if nvm is installed
if [ -d ~/.nvm ]; then
    echo "nvm is already installed"
else
    # Fetch the latest release tag from the nvm GitHub repository
    latest_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')

    # Check if the version was retrieved successfully
    if [[ -n "$latest_version" ]]; then
        echo "The latest version of nvm is: $latest_version"
    else
        echo "Failed to retrieve the latest nvm version."
        exit 1
    fi

    # Download and install the latest version
    echo "Installing nvm version $latest_version..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v"$latest_version"/install.sh 2>/dev/null | bash

    # Verify the installation
    if [ -d ~/.nvm ]; then
        echo "nvm is now installed"

        echo "From the interactive command line:"
        echo "nvm install --lts"
        echo "nvm use --lts"
    fi
fi
