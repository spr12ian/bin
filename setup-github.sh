#!/bin/bash

echo "$0" started

# Check if DEBUG is set to true
if [ "$DEBUG" = "true" ]; then
    set -x # Enable debugging
else
    set +x # Disable debugging
fi

setup-git

debug env | grep GITHUB

if [ -z "${GITHUB_PARENT}" ]; then
    echo "Environment variable GITHUB_PARENT is NOT set"
    exit 1
fi

if [ -z "${GITHUB_USER_EMAIL}" ]; then
    echo "Environment variable GITHUB_USER_EMAIL is NOT set"
    exit 1
fi

if [ -z "${GITHUB_USER_NAME}" ]; then
    echo "Environment variable GITHUB_USER_NAME is NOT set"
    exit 1
fi

git config --global user.email "${GITHUB_USER_EMAIL}"
git config --global user.name "${GITHUB_USER_NAME}"

debug echo "GitHub configurations set successfully."

debug git config --list

GITHUB_HOST_NAME=$(hostnamectl --static)

if grep -q "GitHub-${GITHUB_HOST_NAME}" ~/.ssh/id_ed25519.pub 2>/dev/null; then
    debug echo "GitHub-${GITHUB_HOST_NAME} ssh key exists"
    debug ssh-keygen -lf ~/.ssh/id_ed25519.pub
    debug cat ~/.ssh/id_ed25519.pub
else
    echo "Generating an ed25519 SSH key for GitHub with no passphrase:"
    ssh-keygen -t ed25519 -C "GitHub-${GITHUB_HOST_NAME}" -f ~/.ssh/id_ed25519 -N ""

    echo "Add the SSH key to GitHub by copying its contents:"
    cat ~/.ssh/id_ed25519.pub

    ssh-keygen -lf ~/.ssh/id_ed25519.pub
fi

debug ssh -T git@github.com

echo "$0" finished
