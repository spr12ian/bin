#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt upgrade -y

install_linux_packages

sudo apt --purge autoremove -y

sudo locale-gen en_GB.UTF-8
sudo update-locale LANG=en_GB.UTF-8

sudo systemctl daemon-reexec
sudo systemctl daemon-reload

cat /etc/os-release
hostnamectl
