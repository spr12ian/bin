#!/usr/bin/env bash
set -euo pipefail

sudo apt install -y sqlite3

sqlite3 --version
