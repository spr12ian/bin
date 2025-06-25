#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "${SYMLINKS_SOURCE_DIR}/bash_functions"

# Check argument
if [[ $# -ne 1 ]]; then
  log_error "Usage: $0 <package-name>"
  exit 1
fi

install_apt_package "$1"

version=$(dpkg-query -W -f='${Version}\n' "$1" 2>/dev/null || true)

if [[ -z "$version" ]]; then
  log_error "$1: Version not found"
  exit 1
fi

echo "$1 version: $version"
