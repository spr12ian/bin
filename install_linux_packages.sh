#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$SYMLINKS_SOURCE_DIR/bash_functions"

setup_symbolic_links   # Create symbolic links for these commands to work
                       # Until they are all functions

install_docker                 # Learning about FastAPI, Docker is essential
install_gh                     # GitHub CLI for managing GitHub repositories
install_jq                     # Command_line JSON processor
install_apt_package moreutils  # additional Unix utilities (e.g. sponge)
install_nvm                    # Node Version Manager
install_openssh_server         # SSH server for remote access
install_pipx                   # install & run Python apps in isolated environments
install_poppler_utils          # PDF utilities
install_python                 # Python programming language
install_rust                   # Rust programming language
install_apt_package shellcheck # Shell script analysis tool
install_snap_packages          # Snap package manager
install_sqlite3                # sql command line
install_tree                   # list contents of directories in a tree-like format
install_tesseract_ocr          # Optical Character Recognition
install_vs_code                # Visual Studio Code for code editing
