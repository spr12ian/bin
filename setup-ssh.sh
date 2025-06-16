#!/bin/bash

# Array of SSHD settings
sshd_config_settings=("Port 22" "PermitRootLogin no" "PasswordAuthentication yes")

# Iterate over each setting
for sshd_setting in "${sshd_config_settings[@]}"; do
    # Check if the setting is commented out
    if grep -q "#${sshd_setting}" /etc/ssh/sshd_config; then
        echo "'${sshd_setting}' is commented out in /etc/ssh/sshd_config"
        exit 1
    fi

    # Check if the setting is missing
    if ! grep -q "${sshd_setting}" /etc/ssh/sshd_config; then
        echo "'${sshd_setting}' not declared in /etc/ssh/sshd_config"
        exit 1
    fi
done

sudo systemctl start ssh
sudo systemctl enable ssh
sudo ufw allow ssh

# Array of SSHD settings at end of file
# Match group sftp
# ChrootDirectory /home/%u
# AllowTcpForwarding no
# ForceCommand internal-sftp

sshd_config_settings=("Match group sftp" "ChrootDirectory /home/%u" "AllowTcpForwarding no" "ForceCommand internal-sftp")

# Iterate over each setting
for sshd_setting in "${sshd_config_settings[@]}"; do
    # Check if the setting is commented out
    if grep -q "#${sshd_setting}" /etc/ssh/sshd_config; then
        echo "'${sshd_setting}' is commented out in /etc/ssh/sshd_config"
        exit 1
    fi

    # Check if the setting is missing
    if ! grep -q "${sshd_setting}" /etc/ssh/sshd_config; then
        echo "'${sshd_setting}' not declared in /etc/ssh/sshd_config"
        exit 1
    fi
done

sudo service ssh restart
