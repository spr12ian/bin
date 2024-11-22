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
  cd ${GITHUB_PARENT} || { echo "ERROR: ${GITHUB_PARENT} not found"; exit 1; }

  # Loop through array
  for repo in "${repos[@]}"; do
    echo "Repository: ${repo}"

    if [ ! -d "${repo}" ]; then
      echo "${GITHUB_PARENT}/${repo} does NOT exist, cloning ${repo}..."
      # Try to clone the repository
      if gh repo clone "${GITHUB_USER_NAME}/${repo}"; then
        echo "Success: gh repo clone ${GITHUB_USER_NAME}/${repo}"
      else
        echo "ERROR: gh repo clone ${GITHUB_USER_NAME}/${repo} failed"
      fi
    else
      echo "Syncing ${GITHUB_PARENT}/${repo} ..."
      pushd "${repo}" >/dev/null || {
        echo "ERROR: Could not enter ${repo}"
        continue
      }
      echo "Current directory: $(pwd)"

      # Check if this is a Git repository
      if [[ ! -d .git ]]; then
        echo "ERROR: Not a Git repository."
        exit 1
      fi

      # Check for unstaged changes
      unstaged_changes=$(git status --porcelain | grep -E "^[ ?][MDARC]")

      if [[ -n $unstaged_changes ]]; then
        echo "Unstaged changes detected:"
        echo "$unstaged_changes"
        exit 1
      fi

      # Try to fetch the repository
      if git fetch origin; then
        echo "Success: 'git fetch origin'"
      else
        echo "ERROR: 'git fetch origin' failed"
        exit 1
      fi

      # Get the current branch name
      current_branch=$(git rev-parse --abbrev-ref HEAD)

      local_commit=$(git rev-parse "$current_branch")
      remote_commit=$(git rev-parse "origin/$current_branch")
      base_commit=$(git merge-base "$current_branch" "origin/$current_branch")

      # Check synchronization status
      if [[ "$local_commit" == "$remote_commit" ]]; then
        echo "The local branch is up to date with the remote."
      elif [[ "$local_commit" == "$base_commit" ]]; then
        echo "The local branch is behind the remote. You need to pull changes."
        # Try to pull the repository
        if git pull; then
          echo "Successfully pulled ${repo}"
        else
          echo "ERROR: Pulling ${repo} failed"
        fi
      elif [[ "$remote_commit" == "$base_commit" ]]; then
        echo "The local branch is ahead of the remote. You need to push changes."
      else
        echo "The local and remote branches have diverged. Manual reconciliation needed."
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
