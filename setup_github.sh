#!/usr/bin/env bash
set -euo pipefail

echo "$0 started"

# Enable optional debug output
debug() {
  [[ "${DEBUG:-}" == "true" ]] && "$@"
}

# ─── Sanity Checks ─────────────────────────────────────────────────────────────
: "${GITHUB_PROJECTS_DIR:?Environment variable GITHUB_PROJECTS_DIR is NOT set}"
: "${GITHUB_USER_EMAIL:?Environment variable GITHUB_USER_EMAIL is NOT set}"
: "${GITHUB_USER_NAME:?Environment variable GITHUB_USER_NAME is NOT set}"

# ─── Git Identity Config ────────────────────────────────────────────────────────
set_git_config_if_needed user.email "$GITHUB_USER_EMAIL"
set_git_config_if_needed user.name  "$GITHUB_USER_NAME"

debug git config --list

# ─── SSH Key Setup ──────────────────────────────────────────────────────────────
SSH_KEY=~/.ssh/id_ed25519
GITHUB_HOST_NAME=$(hostnamectl --static)
SSH_COMMENT="GitHub-${GITHUB_HOST_NAME}"

if [[ -f "${SSH_KEY}.pub" ]] && grep -q "$SSH_COMMENT" "${SSH_KEY}.pub"; then
  echo "ℹ️ SSH key already exists with comment '$SSH_COMMENT'"
  debug ssh-keygen -lf "${SSH_KEY}.pub"
else
  echo "🔑 Generating a new ed25519 SSH key with comment '$SSH_COMMENT'"
  ssh-keygen -t ed25519 -C "$SSH_COMMENT" -f "$SSH_KEY" -N ""

  echo "📋 Add this SSH public key to GitHub:"
  cat "${SSH_KEY}.pub"

  ssh-keygen -lf "${SSH_KEY}.pub"
fi

# ─── Test SSH Connection ────────────────────────────────────────────────────────
debug ssh -T git@github.com || true

echo "$0 finished"
