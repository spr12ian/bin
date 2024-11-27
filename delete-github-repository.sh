#!/bin/bash

if [ $# -eq 1 ]; then
    repo=$1
else
    echo "repo name required"
    exit 1
fi

if gh repo delete "${repo}"; then
    echo "The local ${repo} directory may still exist"
fi
