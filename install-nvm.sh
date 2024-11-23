#!/bin/bash

retval=$(command -v nvm); echo "retval: ${retval}"
exit
#trap 'echo "Executing: $BASH_COMMAND"' DEBUG
# Check if nvm is installed
if command -v nvm &> /dev/null; then
    echo "nvm is installed. Version: $(nvm --version)"
else
    echo "nvm is not installed"
fi

exit

# Check if git is installed
if command -v nvm &> /dev/null; then
    echo "nvm is installed. Version: $(nvm --version)"
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
    echo "Verifying nvm installation..."
    source ~/.bashrc
    nvm --version
fi
