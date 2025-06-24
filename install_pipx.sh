#!/usr/bin/env bash
set -euo pipefail

install_apt_package pipx

pipx --version

install_pipx_packages
