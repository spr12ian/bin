#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
source "$SYMLINKS_SOURCE_DIR/bash_functions"

setup_symbolic_links   # Create symbolic links for these commands to work
                       # Until they are all functions

install_apt_package age             # Secure file encryption
install_apt_package graphviz        # Graphviz
install_apt_package jq              # Command_line JSON processor
install_apt_package moreutils       # Additional Unix utilities (e.g. sponge)
install_apt_package node-typescript # Additional Unix utilities (e.g. sponge)
install_apt_package poppler-utils   # PDF utilities
install_apt_package shellcheck      # Shell script analysis tool
install_apt_package sqlite3         # Sql command line
install_apt_package tesseract_ocr   # Optical Character Recognition
install_asdf                        # Version Manager & LTS node.js
install_gh                          # GitHub CLI for managing GitHub repositories
install_npm                         # Version Manager & LTS node.js
install_openssh_server              # SSH server for remote access
install_pipx                        # Install & run Python apps in isolated environments
install_python                      # Python programming language
install_rust                        # Rust programming language
install_snap_packages               # Snap package manager
install_vs_code                     # Visual Studio Code for code editing
