#!/bin/bash

sudo apt update
sudo apt upgrade -y

install-linux-packages.sh

sudo apt autoremove -y
sudo apt --purge autoremove -y

cat /etc/os-release
hostnamectl
