#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# Optional debugging
# ─────────────────────────────────────────────
if [[ "${DEBUG:-}" == "true" ]]; then
  set -x
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

# ─────────────────────────────────────────────
# Lockfile cleanup
# ─────────────────────────────────────────────
LOCKFILE="$HOME/.gitconfig.lock"
if [[ -e "$LOCKFILE" ]]; then
  echo "⚠️ Lock file exists: $LOCKFILE"
  ls -l "$LOCKFILE"
  if lsof "$LOCKFILE" >/dev/null 2>&1; then
    echo "❌ The lock file is currently in use. Not removing."
    exit 1
  else
    echo "✅ Lock file appears stale. Removing..."
    rm -v "$LOCKFILE"
  fi
else
  echo "✅ No lock file present."
fi

# ─────────────────────────────────────────────
# Run Git setup (safe)
# ─────────────────────────────────────────────
setup_github

# ─────────────────────────────────────────────
# Fetch GitHub repositories
# ─────────────────────────────────────────────
readarray -t repos < <(
  curl -s "https://api.github.com/users/${GITHUB_USER_NAME}/repos" |
    jq -r '.[].name'
)

howManyRepos=${#repos[@]}
if [[ $howManyRepos -eq 0 ]]; then
  echo "⚠️ No GitHub repos found for ${GITHUB_USER_NAME}"
  exit 0
fi

echo "🔍 Found $howManyRepos repositories for ${GITHUB_USER_NAME}"

mkdir -p "${GITHUB_PROJECTS_DIR}"
cd "${GITHUB_PROJECTS_DIR}" || {
  echo "❌ Cannot cd to ${GITHUB_PROJECTS_DIR}"
  exit 1
}

# ─────────────────────────────────────────────
# Clone or sync each repo
# ─────────────────────────────────────────────
errors=0

for repo in "${repos[@]}"; do
  echo "─────────────────────────────────────────────"
  echo "🔧 Processing ${repo}"

  if [[ ! -d "$repo" ]]; then
    echo "📥 Cloning ${repo}..."
    if gh repo clone "${GITHUB_USER_NAME}/${repo}"; then
      echo "✅ Cloned ${repo}"
    else
      echo "❌ Failed to clone ${repo}"
      ((errors++))
      continue
    fi
  else
    echo "🔄 Syncing ${repo}..."
    pushd "$repo" >/dev/null || {
      echo "❌ Failed to enter ${repo}"
      ((errors++))
      continue
    }

    if [[ ! -d .git ]]; then
      echo "❌ ${repo} is not a Git repository — skipping"
      popd >/dev/null
      ((errors++))
      continue
    fi

    if [[ -n $(git diff --name-only) ]]; then
      echo "⚠️ Unstaged changes in ${repo}, skipping"
      popd >/dev/null
      ((errors++))
      continue
    fi

    if [[ -n $(git diff --cached --name-only) ]]; then
      echo "⚠️ Staged but uncommitted changes in ${repo}, skipping"
      popd >/dev/null
      ((errors++))
      continue
    fi

    if ! git fetch origin; then
      echo "❌ git fetch failed for ${repo}"
      popd >/dev/null
      ((errors++))
      continue
    fi

    current_branch=$(git rev-parse --abbrev-ref HEAD)
    local_commit=$(git rev-parse "$current_branch")
    remote_commit=$(git rev-parse "origin/$current_branch")
    base_commit=$(git merge-base "$current_branch" "origin/$current_branch")

    if [[ "$local_commit" == "$remote_commit" ]]; then
      echo "✅ ${repo} is up to date"
    elif [[ "$local_commit" == "$base_commit" ]]; then
      echo "⬇️  ${repo} is behind — pulling"
      if git pull; then
        echo "✅ Pulled ${repo}"
      else
        echo "❌ Pull failed for ${repo}"
        ((errors++))
      fi
    elif [[ "$remote_commit" == "$base_commit" ]]; then
      echo "⬆️  ${repo} is ahead of remote — push required"
    else
      echo "⚠️ ${repo} has diverged — manual reconciliation required"
    fi

    if command -v remove_ignored_files_from_git >/dev/null; then
      remove_ignored_files_from_git
    fi

    popd >/dev/null || {
      echo "❌ Could not return to parent directory"
      ((errors++))
      continue
    }
  fi
done

# ─────────────────────────────────────────────
# Final report
# ─────────────────────────────────────────────
echo "─────────────────────────────────────────────"
if [[ $errors -eq 0 ]]; then
  echo "✅ All repositories processed successfully"
  exit 0
else
  echo "⚠️ $errors repositories had issues"
  exit 1
fi
