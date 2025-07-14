#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 2 ]; then
  repo=$1
  repoType=$2
else
  echo "repo name and type required"
  echo "Use AppEngine for a quick setup"
  echo "See full list at  https://github.com/github/gitignore"
  exit 1
fi

repoDirectory="${GITHUB_PROJECTS_DIR}/${repo}"
if [ -d "${repoDirectory}" ]; then
  echo "${repoDirectory} already exists"
  exit 1
fi

cd "${GITHUB_PROJECTS_DIR}" || {
  echo cd "${GITHUB_PROJECTS_DIR}" failed
  exit 1
}

gh repo create "${repo}" --add-readme --description "${repoType} repository" --public --gitignore "${repoType}" --license MIT --clone

cd "${repoDirectory}" || {
  echo cd "${repoDirectory}" failed
  exit 1
}

ls -al
git status
