#!/usr/bin/env bash
set -euo pipefail

log_block_start

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

log_block_finish

