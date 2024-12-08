#!/bin/bash

if [ $# -gt 1 ]; then
    echo "Too many parameters!"
    exit
fi

if [ $# -eq 0 ]; then # if no arguments provided, prompt user
    echo "What repository should I use?"
    read -r repo
fi

if [ $# -eq 1 ]; then
    repo=$1
fi

repoDir="${GITHUB_PARENT}/${repo}"

cd "${repoDir}" || {
    echo "ERROR: cd ${repoDir} failed"
    exit
}

./setup-development-environment

code .
