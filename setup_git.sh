#!/usr/bin/env bash
set -euo pipefail

echo "$0" started

# Check if DEBUG is set to true
if [[ "${DEBUG:-}" == "true" ]]; then
    set -x # Enable debugging
else
    set +x # Disable debugging
fi

# Check if git is installed
if ! command -v git &>/dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi

debug git version

git config --global core.autocrlf input
git config --global core.fileMode false
git config --global core.ignoreCase false
git config --global init.defaultBranch main
git config --global pull.rebase merges

debug echo "Git configurations set successfully."

echo "$0" finished
