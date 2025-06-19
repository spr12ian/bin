#!/usr/bin/env bash
set -euo pipefail

original_dir="${GITHUB_PARENT}/bin"
target_dir="$HOME/.symlinks/bin"
mkdir -p "${target_dir}"

# Check original directory
if [ ! -d "${original_dir}" ]; then
    echo "Original directory does not exist: ${original_dir}"
    exit 1
fi

# Check target directory is writable
if [ ! -w "${target_dir}" ]; then
    echo "Target directory is not writable: ${target_dir}"
    exit 1
fi

shopt -s nullglob
files=("${original_dir}"/*.sh)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No .sh files found in ${original_dir}"
    exit 0
fi

for file in "${files[@]}"; do
    [[ -f "$file" ]] || {
        echo "Original is not a regular file: $file"
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

for file in "${original_dir}"/*; do
    # Skip if it's a directory
    [[ -d "$file" ]] && continue

    # Skip if filename ends with .sh
    if [[ "$file" == *.sh ]]; then
        continue
    fi

    ls -l "$file"
done

ls -lL "${target_dir}"

echo "Symbolic links created in ${target_dir} for all .sh files in ${original_dir}"
