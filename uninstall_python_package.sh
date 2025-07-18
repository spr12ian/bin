#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 1 ]; then
    echo "Too many parameters!"
    exit
fi

if [ $# -eq 0 ]; then # if no arguments provided, prompt user
    echo "What package should I uninstall?"
    read -r package
fi

if [ $# -eq 1 ]; then
    package=$1
fi

log_file="uninstall-pip-${package}.log"
error_log_file="uninstall-pip-${package}-error.log"

echo "Uninstalling ${package}"
python3 -m pip uninstall -y "${package}" >"${log_file}" 2>"${error_log_file}"

# Check if the file exists and its size is zero
if [ -f "$log_file" ] && [ ! -s "$log_file" ]; then
    rm "$log_file"
fi

if [ -f "$error_log_file" ] && [ ! -s "$error_log_file" ]; then
    rm "$error_log_file"
fi

python3 -m pip list --outdated
