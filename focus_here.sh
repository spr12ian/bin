#!/usr/bin/env bash
set -euo pipefail

[[ "${DEBUG:-false}" == "true" ]] && set -x

AUTO_PUSH_WIP=${GITHUB_AUTO_PUSH_WIP:-true}
TAG_EOD=${GITHUB_TAG_EOD:-false}

setup_environment() {
  setup_github
  mkdir -p "${GITHUB_PROJECTS_DIR}"
  cd "${GITHUB_PROJECTS_DIR}" || {
    echo "ERROR: ${GITHUB_PROJECTS_DIR} not found"
    exit 1
  }
}

fetch_repos() {
  curl -s "https://api.github.com/users/${GITHUB_USER_NAME}/repos" |
    jq -r '.[].name'
}

clone_or_update_repo() {
  local repo=$1
  if [[ ! -d "$repo" ]]; then
    echo "$repo not found, cloning..."
    if gh repo clone "${GITHUB_USER_NAME}/${repo}"; then
      echo "✅ Cloned $repo"
    else
      echo "❌ Failed to clone $repo"
    fi
  else
    echo "📁 Updating $repo"
    sync_repo "$repo"
  fi
}

sync_repo() {
  local repo=$1
  pushd "$repo" >/dev/null || return

  [[ -d .git ]] || {
    echo "❌ $repo is not a Git repository"
    popd >/dev/null
    return
  }

  handle_wip_changes "$repo"
  git fetch origin || echo "⚠️ Fetch failed for $repo"
  ensure_feature_branch
  sync_with_remote "$repo"
  clean_ignored
  maybe_tag_eod "$repo"

  popd >/dev/null
}

handle_wip_changes() {
  local repo=$1

  local unstaged
  local staged

  unstaged=$(git diff --name-only)
  staged=$(git diff --cached --name-only)

  if [[ -n "$unstaged" || -n "$staged" ]]; then
    echo "🔧 Uncommitted work in $repo"
    if [[ "$AUTO_PUSH_WIP" == "true" ]]; then
      git add -A
      git commit -m "WIP: auto-commit on $(date +%F_%T)" || echo "ℹ️ Nothing to commit"
      git push || echo "⚠️ Push failed"
    else
      echo "❗ AUTO_PUSH_WIP is disabled; skipping commit"
    fi
  fi
}

ensure_feature_branch() {
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$current_branch" == "main" ]]; then
    local new_branch="feat/auto-${GITHUB_USER_NAME}-$(date +%F)"
    echo "🌿 Switching to $new_branch"

    if git show-ref --verify --quiet "refs/heads/$new_branch"; then
      git checkout "$new_branch"
    else
      git checkout -b "$new_branch"
    fi

    if ! git rev-parse --quiet --verify "origin/$new_branch" >/dev/null; then
      git push -u origin "$new_branch"
    fi
  fi
}

sync_with_remote() {
  local repo=$1
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)

  local local_commit remote_commit base_commit
  local_commit=$(git rev-parse "$branch")
  remote_commit=$(git rev-parse --quiet --verify "origin/$branch" 2>/dev/null || echo "")
  base_commit=$(git merge-base "$branch" "origin/$branch" 2>/dev/null || echo "")

  if [[ "$local_commit" == "$remote_commit" ]]; then
    echo "✅ $branch is up to date"
  elif [[ "$local_commit" == "$base_commit" ]]; then
    echo "⬇️ $branch is behind; pulling"
    git pull || echo "❌ Pull failed"
  elif [[ "$remote_commit" == "$base_commit" ]]; then
    echo "⬆️ $branch is ahead; push needed"
  else
    echo "⚠️ Branch $branch has diverged from origin; manual resolution required"
  fi
}

maybe_tag_eod() {
  local repo=$1
  if [[ "$TAG_EOD" == "true" ]]; then
    local tag="eod-${repo}-$(date +%F)"
    echo "🏷️ Tagging snapshot: $tag"
    git tag -f "$tag" || echo "⚠️ Failed to tag $tag"
    git push origin "$tag" || echo "⚠️ Failed to push tag $tag"
  fi
}

clean_ignored() {
  if command -v remove_ignored_files_from_git >/dev/null; then
    remove_ignored_files_from_git
  fi
}

main() {
  setup_environment

  mapfile -t repos < <(fetch_repos)

  if [[ "${#repos[@]}" -eq 0 ]]; then
    echo "❌ No GitHub repos found for ${GITHUB_USER_NAME}"
    exit 1
  fi

  echo "📦 Found ${#repos[@]} repos to process"

  for repo in "${repos[@]}"; do
    clone_or_update_repo "$repo"
  done
}

main "$@"
