#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
# Constants and Initial Setup
# ────────────────────────────────────────────────────────────────────────────────
SYMLINKS_BIN_DIR="${SYMLINKS_BIN_DIR:-$HOME/.symlinks/bin}"
DEBUG_LOG="${DEBUG_LOG:-/tmp/$(basename "$0").log}"

# ────────────────────────────────────────────────────────────────────────────────
# Logging
# ────────────────────────────────────────────────────────────────────────────────
# Basic logger: always show errors and warnings
log_error() { echo "❌ $*" >&2; }
log_warn()  { echo "⚠️  $*" >&2; }
log_info()  { echo "ℹ️  $*"; }

# Optional debug output: calls command quietly unless DEBUG is set
debug() {
  if [[ "${DEBUG:-}" =~ ^([Tt]rue|1)$ ]]; then
    "$@"
  else
    "$@" &>/dev/null
  fi
}

# Logging via debug(), conditional on DEBUG
log_debug() {
  debug log_info "[DEBUG] $*"
}

# Log when sourced
log_sourced() {
  debug log_info "Sourced: ${BASH_SOURCE[1]} (by ${BASH_SOURCE[2]:-shell})"
}

# Function-level debug logging with indentation
_debug_log() {
  local msg="$1"
  local indent=""
  for ((i = ${#FUNCNAME[@]} - 2; i > 0; i--)); do
    indent+="  "
  done
  local timestamp
  timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  echo "${timestamp} ${indent}${msg}" >>"$DEBUG_LOG"
}

log_function_start()  { _debug_log "→ Starting ${FUNCNAME[1]}"; }
log_function_finish() { _debug_log "← Finished ${FUNCNAME[1]}"; }

# ────────────────────────────────────────────────────────────────────────────────
# Guard to Prevent Re-sourcing
# ────────────────────────────────────────────────────────────────────────────────
guard_source() {
  local guard_var="$1"
  if [[ "${!guard_var:-}" == "1" ]]; then
    log_debug "Guard '$guard_var' already set, skipping re-source."
    return 0
  fi
  printf -v "$guard_var" "1"
  log_debug "Guard '$guard_var' set, sourcing for the first time."
}

guard_source __SOURCE_BASH_FUNCTIONS_LOADED

# ────────────────────────────────────────────────────────────────────────────────
# Execution Detection
# ────────────────────────────────────────────────────────────────────────────────
is_this_script_executed() {
  [[ "${BASH_SOURCE[0]}" == "${0}" ]]
}

stop_if_executed() {
  if is_this_script_executed; then
    log_error "${BASH_SOURCE[0]} must not be executed"
    return 1
  fi
}

stop_if_sourced() {
  if ! is_this_script_executed; then
    log_error "${BASH_SOURCE[0]} must not be sourced."
    return 1
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Utility
# ────────────────────────────────────────────────────────────────────────────────

install_apt_package() {
    log_function_start

    pkg="$1"

    if dpkg -s "$pkg" >/dev/null 2>&1; then
        log_info "$pkg is already installed"
    else
        log_info "Installing $pkg..."
        if sudo apt install -y "$pkg"; then
            log_info "$pkg successfully installed"
        else
            log_warn "Failed to install $pkg"
        fi
    fi

    log_function_finish
}

install_pipx_package() {
  log_function_start

  local pkg="$1"

  if pipx list --json | jq -e --arg pkg "$pkg" 'has($pkg)' >/dev/null; then
    log_info "✅ pipx package '$pkg' is already installed"
  else
    log_info "⬇️  Installing pipx package '$pkg'..."
    if pipx install -y "$pkg"; then
      log_info "✅ Successfully installed '$pkg'"
    else
      log_warn "⚠️  Failed to install '$pkg'"
    fi
  fi

  log_function_finish
}

run_local() {
  local cmd="$1"
  shift

  local local_cmd="$SYMLINKS_BIN_DIR/$cmd"

  if [ ! -x "$local_cmd" ]; then
    log_warn "Command '$cmd' not found or not executable in $SYMLINKS_BIN_DIR."
    return 1
  fi

  local resolved
  resolved="$(command -v "$cmd" 2>/dev/null)"
  if [ "$resolved" != "$local_cmd" ]; then
    log_warn "Command '$cmd' is not resolved to $SYMLINKS_BIN_DIR first in PATH (resolved to $resolved)."
    return 1
  fi

  "$local_cmd" "$@"
}

source_if_exists() {
  local file="$1"
  if [ -f "$file" ]; then
    # shellcheck source=/dev/null
    source "$file"
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Post-load Source Message
# ────────────────────────────────────────────────────────────────────────────────
if ! is_this_script_executed; then
  log_sourced
fi
