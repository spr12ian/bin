#!/bin/bash

uname -s

# Detect Windows 11
shopt -s nocasematch
if [[ "$(uname -r)" == *"Microsoft"* ]]; then
  echo "Running on Windows 11 (likely WSL)"
  # Further check if it's WSL:
  if [[ -f /proc/sys/kernel/osrelease ]] && [[ "$(cat /proc/sys/kernel/osrelease)" == *"Microsoft"* ]]; then
     echo "Confirmed: Running inside WSL."
  fi
  exit 0
fi
shopt -u nocasematch  # Restore default case sensitivity

# Detect Linux
if [[ "$(uname -s)" == "Linux" ]]; then
  echo "Running on Linux"
  exit 0
fi

# Detect macOS (for completeness, although not requested)
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Running on macOS"
    exit 0
fi

echo "Operating system not detected or not supported"
exit 1