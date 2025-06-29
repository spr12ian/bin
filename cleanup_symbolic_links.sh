#!/usr/bin/env bash
set -euo pipefail

original_dir="${GITHUB_PARENT_DIR}/bin"
target_dir="$HOME/.symlinks/bin"

# Check original directory
if [ ! -d "${original_dir}" ]; then
  echo "Original directory does not exist: ${original_dir}"
  exit 1
fi

# Check target directory exists
if [ ! -d "${target_dir}" ]; then
  echo "Target directory does not_exist: ${target_dir}"
  exit 1
fi

find "$target_dir" -type l | while read -r symlink; do
    target=$(readlink -f "$symlink")
    if [[ "$target" == "$original_dir"* ]]; then
        echo "Removing symlink: $symlink -> $target"
        rm "$symlink"
    fi
done

ls -al "$target_dir"
