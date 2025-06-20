#!/usr/bin/env bash
set -euo pipefail

SYMLINKS_SOURCE_DIR="$HOME/.symlinks/source"
# shellcheck disable=SC1091
source "${SYMLINKS_SOURCE_DIR}/bash-functions"

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

install_apt_package $1
