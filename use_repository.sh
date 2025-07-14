#!/usr/bin/env bash
set -euo pipefail

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

repoDir="${GITHUB_PROJECTS_DIR}/${repo}"

cd "${repoDir}" || {
  echo "ERROR: cd ${repoDir} failed"
  exit
}

./setup_development_environment

code .
