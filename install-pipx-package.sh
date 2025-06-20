#!/usr/bin/env bash
set -euo pipefail

SYMLINKS_SOURCE_DIR="$HOME/.symlinks/source"

# shellcheck disable=SC1091
source "${SYMLINKS_SOURCE_DIR}/bash-functions"

# Check argument
if [[ $# -ne 1 ]]; then
  log_error "Usage: $0 <package-name>"
  exit 1
fi

install_pipx_package "$1"
