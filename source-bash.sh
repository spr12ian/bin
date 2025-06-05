#!/usr/bin/env bash
set -euo pipefail

LOCAL_BIN="${LOCAL_BIN:-$HOME/.local/bin}"

# Prevent re-sourcing
guard_source() {
  local guard_var="$1"
  if [[ "${!guard_var:-}" == "1" ]]; then return 0; fi
  printf -v "$guard_var" "1"
}
guard_source __SOURCE_BASH_LOADED

log_error() { echo "❌ $*" >&2; }
log_info() { echo "ℹ️  $*"; }
log_warn() { echo "⚠️  $*" >&2; }

# Run a command from $LOCAL_BIN if it exists and is the first in PATH
run_local() {
  local cmd="$1"
  shift

  local local_cmd="$LOCAL_BIN/$cmd"

  # Check: file exists and is executable in LOCAL_BIN
  if [ ! -x "$local_cmd" ]; then
    log_warn "Command '$cmd' not found or not executable in $LOCAL_BIN."
    return 1
  fi

  # Check: it's the first found in PATH
  local resolved
  resolved="$(command -v "$cmd" 2>/dev/null)"
  if [ "$resolved" != "$local_cmd" ]; then
    log_warn "Command '$cmd' is not resolved to $LOCAL_BIN first in PATH (resolved to $resolved)."
    return 1
  fi

  # Safe to run
  "$local_cmd" "$@"
}

source_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
}

stop_if_executed() {
  if this_script_is_executed; then
    log_error "${BASH_SOURCE[0]} must not be executed"
    exit 1
  fi
}

stop_if_sourced() {
  if ! this_script_is_executed; then
    log_error "${BASH_SOURCE[0]} must not be sourced."
    exit 1
  fi
}

this_script_is_executed() {
  # ${0} is 'bash' if sourced or the called top level function otherwise
  [[ "${BASH_SOURCE[0]}" == "${0}" ]]
}

[[ "${DEBUG_SOURCED:-}" == "1" ]] && log_info "Sourced: ${BASH_SOURCE[0]}"
