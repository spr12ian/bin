#!/bin/bash

setup-github.sh

# List public repositories for a specific user
# Filter for specific fields using jq
# Assign results to array repos
readarray -t repos < <(curl -s "https://api.github.com/users/${GITHUB_USER_NAME}/repos" | jq -r '.[].name')

# Get array length
howManyRepos=${#repos[@]}

if [ "${howManyRepos}" -gt 0 ]; then
  echo "Number of repos: ${howManyRepos}"

  mkdir -p "${GITHUB_PARENT}"
  cd ${GITHUB_PARENT} || exit

  # Loop through array
  for repo in "${repos[@]}"; do
    echo "Repository: ${repo}"
    if [ ! -d "${repo}" ]; then
      echo "${GITHUB_PARENT}/${repo} folder does NOT exist, cloning ${repo}..."
      # Try to clone the repository
      if gh repo clone "${GITHUB_USER_NAME}/${repo}"; then
        echo "Successfully cloned ${repo}"
      else
        echo "ERROR: Cloning ${repo} failed"
      fi
    else
      echo "${GITHUB_PARENT}/${repo} folder already exists, pulling ${repo}..."
      pushd "${repo}" >/dev/null || {
        echo "ERROR: Could not enter ${repo}"
        continue
      }
      echo "Current directory: $(pwd)"
      # Try to pull the repository
      if git pull; then
        echo "Successfully pulled ${repo}"
      else
        echo "ERROR: Pulling ${repo} failed"
      fi
      # Clean up ignored files if applicable
      if type remove-ignored-files-from-git.sh >/dev/null 2>&1; then
        #remove-ignored-files-from-git.sh >/dev/null 2>&1
        remove-ignored-files-from-git.sh
      else
        echo "remove-ignored-files-from-git command not found, skipping..."
      fi
      popd >/dev/null || {
        echo "ERROR: Could not return to previous directory"
        exit 1
      }
    fi

    echo "Processing ${repo} complete."
  done
else
  echo "No GitHub repos found for ${GITHUB_USER_NAME}"
fi
