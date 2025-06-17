#!/bin/bash
set -euo pipefail

source_dir="${GITHUB_PARENT}/bin"
target_dir="$HOME/.local/bin"
mkdir -p "${target_dir}"

# Check source directory
if [ ! -d "${source_dir}" ]; then
    echo "Source directory does not exist: ${source_dir}"
    exit 1
fi

# Check target directory is writable
if [ ! -w "${target_dir}" ]; then
    echo "Target directory is not writable: ${target_dir}"
    exit 1
fi

shopt -s nullglob
files=("${source_dir}"/*.sh)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No .sh files found in ${source_dir}"
    exit 0
fi

for file in "${files[@]}"; do
    [[ -f "$file" ]] || {
        echo "Source is not a regular file: $file"
        continue
    }

    # Check if file has a shebang line
    grep -q '^#!' "$file" || {
        echo "WARNING: $file is missing a shebang line"
        continue
    }

    command_file=$(basename -- "${file}" .sh)

    if [[ "$command_file" == source-* ]]; then
        mode=600
    else
        mode=700
    fi

    chmod "$mode" "$file"

    link_path="${target_dir}/${command_file}"

    ln -sf "${file}" "${link_path}"
done

for file in "${source_dir}"/*; do
    # Skip if it's a directory
    [[ -d "$file" ]] && continue

    # Skip if filename ends with .sh
    if [[ "$file" == *.sh ]]; then
        continue
    fi

    ls -l "$file"
done

ls -lL "${target_dir}"

echo "Symbolic links created in ${target_dir} for all .sh files in ${source_dir}"
