#!/usr/bin/env bash
set -euo pipefail

install_apt_package sqlite3

sqlite3 --version
