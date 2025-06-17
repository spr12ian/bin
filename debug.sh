#!/bin/bash
set -euo pipefail

debug() {
  if [[ "${DEBUG:-}" == "true" ]]; then
    "$@"
  else
    "$@" &>/dev/null
  fi
}
