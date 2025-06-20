#!/usr/bin/env bash
set -euo pipefail

echo "Checking if running in WSL..."
if grep -qEi "(microsoft|wsl)" /proc/version &> /dev/null ; then
    echo "✅ Running inside WSL"
    IN_WSL=true
else
    echo "✅ Not running inside WSL"
    IN_WSL=false
fi

echo "Checking for VS Code..."
if command -v code >/dev/null 2>&1; then
    echo "✅ VS Code CLI is available."
else
    if [[ "$IN_WSL" == true ]]; then
        echo "❌ VS Code CLI not available in WSL."
        echo "👉 Please ensure VS Code is installed on Windows and that the Remote - WSL extension is enabled."
        echo "👉 You should NOT install native Linux VS Code inside WSL."
        exit 1
    else
        echo "❌ VS Code not found. Installing..."

        # Detect if apt is available
        if command -v apt >/dev/null 2>&1; then
            echo "Using apt to install VS Code..."

            sudo apt update
            sudo apt install -y wget gpg apt-transport-https

            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
            sudo install -o root -g root -m 644 /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
            rm /tmp/microsoft.gpg

            if ! grep -q "packages.microsoft.com/repos/code" /etc/apt/sources.list.d/vscode.list 2>/dev/null; then
                echo "Adding VS Code repository..."
                echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
            else
                echo "VS Code repository already present."
            fi

            sudo apt update
            sudo apt install -y code

            echo "✅ VS Code installed."
        else
            echo "ERROR: 'apt' not found. Cannot install VS Code automatically on this system."
            echo "Please install VS Code manually."
            exit 1
        fi
    fi
fi
