#!/usr/bin/env bash
set -euo pipefail

# Recursively find and rename files with hyphens in the name
find . -depth -type f -name '*-*' | while IFS= read -r file; do
  dir=$(dirname "$file")
  base=$(basename "$file")
  new_base="${base//-/_}"
  new_path="$dir/$new_base"

  if [ "$file" != "$new_path" ]; then
    echo "Renaming: $file → $new_path"
    mv -i -- "$file" "$new_path"
  fi
done
