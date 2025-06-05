#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$HOME/.local/bin/source-bash"

guard_source __SOURCE_DEBUG_LOADED

set_debug_log() {
    # Location of the debug log
    DEBUG_LOG="${DEBUG_LOG:-/tmp/$(basename "$0").log}"
    echo "The debug log file can be found at $DEBUG_LOG"
}

# Log a message with optional timestamp and indentation
_debug_log() {
    local msg="$1"
    local indent=""
    for ((i = ${#FUNCNAME[@]} - 2; i > 0; i--)); do
        indent+="  "
    done
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    if declare -p DEBUG_LOG &>/dev/null; then
        echo "${timestamp} ${indent}${msg}" >>"$DEBUG_LOG"
    else
        echo "${timestamp} ${indent}${msg}"
    fi
}

log_block_start() {
    _debug_log "→ Starting ${FUNCNAME[1]}"
}

log_block_finish() {
    _debug_log "← Finished ${FUNCNAME[1]}"
}


