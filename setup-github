#!/bin/bash

setup-git

env | grep GITHUB

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

git config --global user.email ${GITHUB_USER_EMAIL}
git config --global user.name ${GITHUB_USER_NAME}

git config --list
