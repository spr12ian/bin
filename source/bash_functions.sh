#!/usr/bin/env bash
# shellcheck shell=bash

# ────────────────────────────────────────────────────────────────────────────────
# SAFETY WRAPPER — Protect login shells
# Do NOT use `set -euo pipefail` globally in a sourced file.
# ────────────────────────────────────────────────────────────────────────────────

__source_bash_functions_guard_var="__SOURCE_BASH_FUNCTIONS_LOADED"
if [[ "${!__source_bash_functions_guard_var:-}" == "1" ]]; then
  return 0
fi
printf -v "$__source_bash_functions_guard_var" "1"

# ────────────────────────────────────────────────────────────────────────────────
# LOGGING
# ────────────────────────────────────────────────────────────────────────────────

log_error() { echo "❌ $*" >&2; }
log_warn() { echo "⚠️  $*" >&2; }
log_info() { echo "ℹ️  $*"; }

debug() {
  if [[ "${DEBUG:-}" =~ ^([Tt]rue|1)$ ]]; then "$@"; else "$@" &>/dev/null; fi
}

log_debug() {
  debug log_info "[DEBUG] $*"
}

# ────────────────────────────────────────────────────────────────────────────────
# GUARDS
# ────────────────────────────────────────────────────────────────────────────────

is_sourced() {
  [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

stop_if_executed_directly() {
  if ! is_sourced; then
    log_error "${BASH_SOURCE[0]} must not be executed directly."
    return 1
  fi
}

# Only enforce if needed:
stop_if_executed_directly

# ────────────────────────────────────────────────────────────────────────────────
# Constants and Initial Setup
# ────────────────────────────────────────────────────────────────────────────────
SYMLINKS_BIN_DIR="${SYMLINKS_BIN_DIR:-$HOME/.symlinks/bin}"
DEBUG_LOG="${DEBUG_LOG:-/tmp/$(basename -- "$0").log}"

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

log_function_start() { _debug_log "→ Starting ${FUNCNAME[1]}"; }
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

about() {
  local args=()

  if [ "$#" -eq 0 ]; then
    if [[ $- == *i* ]]; then
      echo -n "What commands are you asking about?> "
      read -r input
      read -ra args <<<"$input" # Split input into array
    else
      echo "ℹ️  No arguments passed and shell is non-interactive — skipping prompt." >&2
      return 1
    fi
  else
    args=("$@")
  fi

  echo "command (builtin)    - prints a description for the command"
  echo "type (builtin)       - indicates how it would be interpreted as a command name"
  whatis whatis 2>/dev/null || true
  whatis which 2>/dev/null || true
  echo

  for cmd in "${args[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "❌ Command not found: $cmd"
      continue
    fi

    echo "🔍 Command: $cmd"

    echo -n "📄 type:         "
    type_result=$(type -t "$cmd" 2>/dev/null || true)
    echo "${type_result:-Not found}"

    echo -n "❓ whatis:       "
    whatis "$cmd" 2>/dev/null || echo "No man page info found"

    if [[ "$type_result" != "function" ]]; then
      echo -n "📍 which:        "
      which "$cmd" 2>/dev/null || echo "Not found"
    fi

    echo -n "📦 command -v:   "
    command -v "$cmd" 2>/dev/null || echo "Not found"

    echo "────────────────────────────────────────────────────────────────────"
  done
}

add_path_if_exists() {
  local position="$1"
  shift

  # Validate position
  case "$position" in
    before|after) ;;
    *)
      echo "❌ Invalid position: $position (use 'before' or 'after')" >&2
      return 1
      ;;
  esac

  local dir resolved added=0

  for dir in "$@"; do
    # Skip empty or non-directory arguments
    [[ -z "$dir" || ! -d "$dir" ]] && continue

    resolved=$(realpath -m "$dir" 2>/dev/null) || continue

    # Skip if already in PATH
    [[ ":$PATH:" == *":$resolved:"* ]] && continue

    # Add to PATH in requested position
    case "$position" in
      before) PATH="$resolved:$PATH" ;;
      after)  PATH="$PATH:$resolved" ;;
    esac

    added=1
  done

  return "$added"  # return 0 if at least one path added, 1 otherwise
}

link_home_dotfiles() {
  local original_dir="${GITHUB_DOTFILES_DIR:?GITHUB_DOTFILES_DIR not set}"
  local target_dir="$HOME"
  local chmod_mode=600

  if [ "$#" -eq 0 ]; then
    echo "ℹ️  No dotfiles passed in"
    return 0
  fi

  if [ ! -d "$original_dir" ]; then
    echo "❌ Original directory does not exist: $original_dir"
    return 1
  fi

  if [ ! -w "$target_dir" ]; then
    echo "❌ Target directory is not writable: $target_dir"
    return 1
  fi

  for filename in "$@"; do
    local src_file="$original_dir/.$filename"
    local dest_file="$target_dir/.$filename"

    if [ ! -f "$src_file" ]; then
      echo "⚠️  File not found: $src_file"
      continue
    fi

    chmod "$chmod_mode" "$src_file"
    ln -sf "$src_file" "$dest_file"
    echo "🔗 Linked $src_file → $dest_file"
  done

  echo "✅ Dotfiles linked into $target_dir"
}

# Return the command type: alias, function, builtin, keyword, or file
command_type() {
  local cmd="$1"
  local kind

  kind=$(type -t "$cmd" 2>/dev/null || true)

  if [[ -z "$kind" ]]; then
    echo "unknown"
    return 1
  fi

  echo "$kind"
  return 0
}

setup_symbolic_links() {
  local project_dir="${GITHUB_PARENT:-$HOME}/bin"
  local symlinks_dir="$HOME/.symlinks"

  link_scripts_in_dir "${project_dir}" "$symlinks_dir/bin" 700
  link_scripts_in_dir "${project_dir}/source" "$symlinks_dir/source" 600

  dot_files=(bash_profile bashrc post_bashrc)
  link_home_dotfiles "${dot_files[@]}"
}

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

# Check if a command exists and is usable
command_exists() {
  local cmd="$1"
  local resolved kind

  _log_debug "Checking command: $cmd"

  if ! resolved=$(command -v "$cmd" 2>/dev/null); then
    _log_debug "Not found in PATH"
    return 1
  fi

  kind=$(command_type "$cmd")

  _log_debug "Type: $kind, Resolved: $resolved"

  if [[ "$kind" != "file" && "$kind" != "unknown" ]]; then
    return 0 # shell builtin, alias, function, etc.
  fi

  if [[ "$kind" == "file" && -x "$resolved" ]]; then
    return 0 # executable file
  fi

  return 1 # Found but not usable
}

command_exists_debug() {
  local cmd="$1"
  local resolved kind real_target

  # Try to resolve via PATH
  if ! resolved=$(command -v "$cmd" 2>/dev/null); then
    echo "❌ Command '$cmd' not found in PATH"
    return 1
  fi

  # Determine the type
  kind=$(type -t "$cmd" 2>/dev/null || true)
  echo "✅ Found: $cmd"
  echo "   Type: ${kind:-unknown}"
  echo "   Resolved path: $resolved"

  # If it's a regular file, verify it's executable
  if [[ "$kind" == "file" ]]; then
    if [ ! -x "$resolved" ]; then
      echo "⚠️  Not executable: $resolved"
      return 1
    fi

    # Detect and resolve symlink
    if [ -L "$resolved" ]; then
      real_target=$(readlink -f "$resolved" 2>/dev/null || realpath "$resolved" 2>/dev/null || echo "Unable to resolve")
      echo "   🔗 Symlink target: $real_target"
    fi
  fi

  return 0
}

link_scripts_in_dir() {
  local original_dir="$1"
  local target_dir="$2"
  local chmod_mode="$3"

  mkdir -p "${target_dir}"

  if [ ! -d "${original_dir}" ]; then
    echo "❌ Original directory does not exist: ${original_dir}"
    return 1
  fi

  if [ ! -w "${target_dir}" ]; then
    echo "❌ Target directory is not writable: ${target_dir}"
    return 1
  fi

  shopt -s nullglob
  local files=("${original_dir}"/*.sh)
  shopt -u nullglob

  if [ ${#files[@]} -eq 0 ]; then
    echo "ℹ️  No .sh files found in ${original_dir}"
    return 0
  fi

  for file in "${files[@]}"; do
    [[ -f "$file" ]] || {
      echo "⚠️  Not a regular file: $file"
      continue
    }

    grep -q '^#!' "$file" || {
      echo "⚠️  Missing shebang: $file"
      continue
    }

    local command_file
    command_file=$(basename -- "${file}" .sh)

    chmod "${chmod_mode}" "$file"
    ln -sf "${file}" "${target_dir}/${command_file}"
  done

  for file in "${original_dir}"/*; do
    [[ -d "$file" || "$file" == *.sh ]] && continue
    ls -l "$file"
  done

  ls -lL "${target_dir}"
  echo "✅ Symbolic links created in ${target_dir} for all .sh files in ${original_dir}"
}

print_path() {
  local i=1
  echo "🔍 Current \$PATH entries:"
  echo "$PATH" | tr ':' '\n' | while read -r dir; do
    if [ -d "$dir" ]; then
      printf "%2d. ✅ %s\n" "$i" "$dir"
    else
      printf "%2d. ❌ %s (not a directory)\n" "$i" "$dir"
    fi
    i=$((i + 1))
  done
}

remove_path() {
  local remove="$1"
  PATH=$(echo "$PATH" | tr ':' '\n' | grep -v -x "$remove" | paste -sd:)
}

# Resolve symlinks to get the actual file path
resolve_command_path() {
  local cmd="$1"

  if ! command_exists "$cmd"; then
    echo "❌ '$cmd' not found or not executable" >&2
    return 1
  fi

  local resolved
  resolved=$(command -v "$cmd")

  if [ -L "$resolved" ]; then
    resolved=$(readlink -f "$resolved" 2>/dev/null || realpath "$resolved" 2>/dev/null || echo "$resolved")
  fi

  echo "$resolved"
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

vcode() {
  local base_dir="${HOME}/projects"

  if [[ $# -eq 0 ]]; then
    echo "Usage: vcode [project1 project2 ...] or vcode --all"
    return 0
  fi

  if [[ $# -eq 1 && -f "${VSCODE_WORKSPACE_DIR}/$1.code-workspace" ]]; then
    # Use existing named workspace file
    code "${VSCODE_WORKSPACE_DIR}/$1.code-workspace"
    return 0
  fi

  # Else, build a temporary workspace file
  local tmp_workspace_dir="/tmp/vcode_workspace_$$"
  mkdir -p "$tmp_workspace_dir"
  local workspace_file="${tmp_workspace_dir}/workspace.code-workspace"

  local folders=()

  if [[ "$1" == "--all" ]]; then
    # Include all immediate subdirectories of ~/projects/
    while IFS= read -r -d '' dir; do
      folders+=("{\"path\": \"$dir\"}")
    done < <(find "$base_dir" -mindepth 1 -maxdepth 1 -type d -print0)

    if [[ ${#folders[@]} -eq 0 ]]; then
      echo "⚠️ No subdirectories found under $base_dir"
      return 0
    fi
  else
    # Manually specified projects
    for project in "$@"; do
      local dir="$base_dir/$project"
      if [[ ! -d "$dir" ]]; then
        echo "❌ '$project' does not exist in $base_dir"
        continue
      fi
      folders+=("{\"path\": \"$dir\"}")
    done

    if [[ ${#folders[@]} -eq 0 ]]; then
      echo "🚫 No valid projects to open"
      return 0
    fi
  fi

  # Write workspace JSON
  printf '{\n  "folders": [\n    %s\n  ]\n}\n' "$(
    IFS=,$'\n'
    echo "${folders[*]}"
  )" >"$workspace_file"

  code "$workspace_file"
}

# ────────────────────────────────────────────────────────────────────────────────
# Post-load Source Message
# ────────────────────────────────────────────────────────────────────────────────
if ! is_this_script_executed; then
  log_sourced
fi
