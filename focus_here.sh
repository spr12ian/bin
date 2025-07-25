#!/usr/bin/env bash
set -euo pipefail

# Check if DEBUG is set to true
if [[ "${DEBUG:-}" == "true" ]]; then
  set -x # Enable debugging
else
  set +x # Disable debugging
fi

# ─────────────────────────────────────────────
# Ensure bash_functions are sourced
# ─────────────────────────────────────────────
BASH_FUNCTIONS="$HOME/.symlinks/source/bash_functions"
if [[ -f "$BASH_FUNCTIONS" ]]; then
  # shellcheck source=/dev/null
  source "$BASH_FUNCTIONS"
else
  echo "❌ Missing $BASH_FUNCTIONS — aborting."
  exit 1
fi

LOCKFILE="$HOME/.gitconfig.lock"

if [[ -e "$LOCKFILE" ]]; then
  echo "⚠️ Lock file exists: $LOCKFILE"
  ls -l "$LOCKFILE"

  # Check if any git process is using it
  if lsof "$LOCKFILE" >/dev/null 2>&1; then
    echo "❌ The lock file is currently in use by another process. Not removing."
    exit 1
  else
    echo "✅ Lock file appears stale. Removing..."
    rm -v "$LOCKFILE"
  fi
else
  echo "✅ No lock file present."
fi

setup_github

# List public repositories for a specific user
# Filter for specific fields using jq
# Assign results to array repos
readarray -t repos < <(curl -s "https://api.github.com/users/${GITHUB_USER_NAME}/repos" | jq -r '.[].name')

# Get array length
howManyRepos=${#repos[@]}

if [ "${howManyRepos}" -gt 0 ]; then
  debug echo "Number of repos: ${howManyRepos}"

  mkdir -p "${GITHUB_PROJECTS_DIR}"
  cd "${GITHUB_PROJECTS_DIR}" || {
    echo "ERROR: ${GITHUB_PROJECTS_DIR} not found"
    exit 1
  }
  debug echo "Parent directory for GitHub repos: $(pwd)"

  # Loop through array
  for repo in "${repos[@]}"; do
    debug echo "Repository: ${repo}"

    if [ ! -d "${repo}" ]; then
      echo "${GITHUB_PROJECTS_DIR}/${repo} does NOT exist, cloning ${repo}..."
      # Try to clone the repository
      if gh repo clone "${GITHUB_USER_NAME}/${repo}"; then
        echo "Success: gh repo clone ${GITHUB_USER_NAME}/${repo}"
      else
        echo "ERROR: gh repo clone ${GITHUB_USER_NAME}/${repo} failed"
      fi
    else
      echo "Syncing ${GITHUB_PROJECTS_DIR}/${repo} ..."
      pushd "${repo}" >/dev/null || {
        echo "ERROR: pushd ${repo} failed"
        continue
      }
      debug echo "Current directory: $(pwd)"

      # Check if this is a Git repository
      if [ ! -d .git ]; then
        echo "ERROR: Not a Git repository."
        exit 1
      fi

      # Check for unstaged changes
      unstaged_changes=$(git diff --name-only)

      if [[ -n $unstaged_changes ]]; then
        echo "Unstaged changes detected:"
        echo "$unstaged_changes"
        exit 1
      fi

      # Check for staged changes
      staged_changes=$(git diff --cached --name-only)

      if [[ -n $staged_changes ]]; then
        echo "The following files are in the staging area:"
        echo "$staged_changes"
        exit 1
      fi

      # Try to fetch the repository
      if ! git fetch origin; then
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
        debug echo "The local branch is up to date with the remote."
      elif [[ "$local_commit" == "$base_commit" ]]; then
        debug echo "The local branch is behind the remote. Trying to pull changes."
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
      if type remove_ignored_files_from_git >/dev/null 2>&1; then
        remove_ignored_files_from_git
      else
        echo "remove_ignored_files_from_git command not found, skipping..."
      fi
      popd >/dev/null || {
        echo "ERROR: Could not return to previous directory"
        exit 1
      }
      debug echo "Current directory: $(pwd)"
    fi

    debug echo "Processing ${repo} complete."
  done
else
  echo "No GitHub repos found for ${GITHUB_USER_NAME}"
fi
