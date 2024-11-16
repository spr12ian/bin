#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Please install Git and try again."
    exit 1
fi
    
git version

git config --global core.autocrlf input
git config --global core.fileMode false
git config --global core.ignoreCase false
git config --global init.defaultBranch main
git config --global pull.rebase false

