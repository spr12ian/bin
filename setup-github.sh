#!/bin/bash

setup-git.sh

# env | grep GITHUB

if [ -z "${GITHUB_HOST_NAME}" ]; then
    echo "Environment variable GITHUB_HOST_NAME is NOT set"
    exit 1
fi

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

git config --list

if grep -q "GitHub-${GITHUB_HOST_NAME}" ~/.ssh/id_ed25519.pub 2>/dev/null; then
    echo "GitHub-${GITHUB_HOST_NAME} ssh key exists"
    ssh-keygen -lf ~/.ssh/id_ed25519.pub
    cat ~/.ssh/id_ed25519.pub
else
    echo "Generating an ed25519 SSH key for GitHub with no passphrase:"
    ssh-keygen -t ed25519 -C "GitHub-${GITHUB_HOST_NAME}" -f ~/.ssh/id_ed25519 -N ""

    echo "Add the SSH key to GitHub by copying its contents:"
    cat ~/.ssh/id_ed25519.pub

    ssh-keygen -lf ~/.ssh/id_ed25519.pub
fi

ssh -T git@github.com
