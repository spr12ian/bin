#!/usr/bin/env bash
set -euo pipefail

echo "$0 started"

# ─── Debug Helper ───────────────────────────────────────────────────────────────
debug() {
  [[ "${DEBUG:-}" == "true" ]] && "$@"
}

# ─── Check Dependencies ────────────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
  echo "❌ Git is not installed. Please install Git and try again."
  exit 1
fi

debug git --version

# ─── Git Config Defaults ────────────────────────────────────────────────────────
set_git_config_if_needed core.autocrlf        input
set_git_config_if_needed core.fileMode        false
set_git_config_if_needed core.ignoreCase      false
set_git_config_if_needed init.defaultBranch   main
set_git_config_if_needed pull.rebase          merges

debug git config --list

echo "$0 finished"
