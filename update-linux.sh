#!/bin/bash

sudo apt update
sudo apt upgrade -y

install-linux-packages

sudo apt --purge autoremove -y

sudo locale-gen en_GB.UTF-8
sudo update-locale LANG=en_GB.UTF-8

cat /etc/os-release
hostnamectl
