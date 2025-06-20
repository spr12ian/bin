#!/usr/bin/env bash
set -euo pipefail

install_apt_package jq

jq --version
