#!/usr/bin/env bash
set -euo pipefail

[[ "${DEBUG:-false}" == "true" ]] && set -x

# ─── Config from env ─────────────────────────────────────────
AUTO_PUSH_WIP=${GITHUB_AUTO_PUSH_WIP:-true}
TAG_EOD=${GITHUB_TAG_EOD:-false}
LOG_FILE=${GITHUB_LOG_FILE:-"focus_here.log"}
MAX_JOBS=${GITHUB_MAX_JOBS:-4}

# ─── Optional logging to a shared file ──────────────────────
[[ -n "$LOG_FILE" ]] && exec &> >(tee -a "$LOG_FILE")

# ─── Required env variables ──────────────────────────────────────
if [[ -z "${GITHUB_USER_NAME:-}" || -z "${GITHUB_PROJECTS_DIR:-}" ]]; then
  echo "❌ GITHUB_USER_NAME and GITHUB_PROJECTS_DIR must be set"
  exit 1
fi

# ─── Positional prefix argument ─────────────────────────────
REPO_PREFIX="${1:-}"
[[ -n "$REPO_PREFIX" ]] && echo "🔍 Filtering repos by prefix: '$REPO_PREFIX'"

# ─── Track counts ───────────────────────────────────────────
repo_total=0
repo_cloned=0
repo_updated=0
repo_failed=0

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
    jq -r '.[].name' |
    grep "^${REPO_PREFIX}" || true
}

clone_or_update_repo() {
  local repo=$1
  ((repo_total++))

  if [[ ! -d "$repo" ]]; then
    echo "⬇️  Cloning $repo ..."
    if gh repo clone "${GITHUB_USER_NAME}/${repo}" &>/dev/null; then
      echo "✅ Cloned $repo"
      ((repo_cloned++))
    else
      echo "❌ Failed to clone $repo"
      ((repo_failed++))
    fi
  else
    echo "🔄 Syncing $repo ..."
    if sync_repo "$repo"; then
      ((repo_updated++))
    else
      echo "❌ Failed to sync $repo"
      ((repo_failed++))
    fi
  fi
}

sync_repo() {
  local repo=$1
  pushd "$repo" >/dev/null || return 1

  [[ -d .git ]] || {
    echo "❌ $repo is not a Git repository"
    popd >/dev/null
    return 1
  }

  handle_wip_changes "$repo"
  git fetch origin &>/dev/null || echo "⚠️ Fetch failed"

  ensure_feature_branch
  sync_with_remote "$repo"
  maybe_tag_eod "$repo"
  clean_ignored

  popd >/dev/null
}

handle_wip_changes() {
  local repo=$1
  local unstaged staged

  unstaged=$(git diff --name-only)
  staged=$(git diff --cached --name-only)

  if [[ -n "$unstaged" || -n "$staged" ]]; then
    echo "🔧 Uncommitted work in $repo"
    if [[ "$AUTO_PUSH_WIP" == "true" ]]; then
      git add -A
      git commit -m "WIP: auto-commit on $(date +%F_%T)" &>/dev/null || echo "ℹ️ Nothing to commit"
      git push &>/dev/null || echo "⚠️ Push failed"
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
    echo "🌿 Switching to branch $new_branch"

    if git show-ref --verify --quiet "refs/heads/$new_branch"; then
      git checkout "$new_branch"
    else
      git checkout -b "$new_branch"
    fi

    if ! git rev-parse --quiet --verify "origin/$new_branch" >/dev/null; then
      git push -u origin "$new_branch" &>/dev/null
    fi
  fi
}

sync_with_remote() {
  local repo=$1
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)

  local_commit=$(git rev-parse "$branch")
  remote_commit=$(git rev-parse --quiet --verify "origin/$branch" 2>/dev/null || echo "")
  base_commit=$(git merge-base "$branch" "origin/$branch" 2>/dev/null || echo "")

  if [[ "$local_commit" == "$remote_commit" ]]; then
    echo "✅ Up to date"
  elif [[ "$local_commit" == "$base_commit" ]]; then
    echo "⬇️ Pulling latest changes"
    git pull &>/dev/null || echo "❌ Pull failed"
  elif [[ "$remote_commit" == "$base_commit" ]]; then
    echo "⬆️ Local ahead; push needed"
  else
    echo "⚠️ Diverged from remote"
  fi
}

maybe_tag_eod() {
  local repo=$1
  if [[ "$TAG_EOD" == "true" ]]; then
    local tag="eod-${repo}-$(date +%F)"
    git tag -f "$tag" &>/dev/null || echo "⚠️ Failed to tag $tag"
    git push origin "$tag" &>/dev/null || echo "⚠️ Failed to push tag $tag"
  fi
}

clean_ignored() {
  if command -v remove_ignored_files_from_git &>/dev/null; then
    remove_ignored_files_from_git
  fi
}

main() {
  setup_environment
  mapfile -t repos < <(fetch_repos)

  if [[ "${#repos[@]}" -eq 0 ]]; then
    echo "❌ No matching repos found"
    exit 0
  fi

  echo "📦 Processing ${#repos[@]} repos in parallel (max ${MAX_JOBS})..."

  local -i running_jobs=0
  for repo in "${repos[@]}"; do
    (
      echo "▶️ $repo"
      clone_or_update_repo "$repo" || echo "❌ $repo failed"
    ) &
    ((running_jobs++))

    if ((running_jobs >= MAX_JOBS)); then
      wait -n || true
      ((running_jobs--))
    fi
  done

  wait || true  # Never abort on a background error
  echo "✅ Done"

  echo
  echo "📊 Summary:"
  echo "  Total:   $repo_total"
  echo "  Cloned:  $repo_cloned"
  echo "  Updated: $repo_updated"
  echo "  Failed:  $repo_failed"
}

main "$@"
