#!/usr/bin/env bash
set -euo pipefail

link_scripts_in_dir() {
    local original_dir="$1"
    local target_dir="$2"
    local chmod_mode="$3"

    mkdir -p "${target_dir}"

    if [ ! -d "${original_dir}" ]; then
        echo "Original directory does not exist: ${original_dir}"
        exit 1
    fi

    if [ ! -w "${target_dir}" ]; then
        echo "Target directory is not writable: ${target_dir}"
        exit 1
    fi

    shopt -s nullglob
    local files=("${original_dir}"/*.sh)
    shopt -u nullglob

    if [ ${#files[@]} -eq 0 ]; then
        echo "No .sh files found in ${original_dir}"
        return
    fi

    for file in "${files[@]}"; do
        [[ -f "$file" ]] || {
            echo "Original is not a regular file: $file"
            continue
        }

        grep -q '^#!' "$file" || {
            echo "WARNING: $file is missing a shebang line"
            continue
        }

        local command_file
        command_file=$(basename -- "${file}" .sh)
        chmod "${chmod_mode}" "$file"
        ln -sf "${file}" "${target_dir}/${command_file}"
    done

    for file in "${original_dir}"/*; do
        [[ -d "$file" || "$file" == *.sh ]] && continue
        ls -l "$file"
    done

    ls -lL "${target_dir}"
    echo "Symbolic links created in ${target_dir} for all .sh files in ${original_dir}"
}

link_scripts_in_dir "${GITHUB_PARENT}/bin" "$HOME/.symlinks/bin" 700
link_scripts_in_dir "${GITHUB_PARENT}/bin/source" "$HOME/.symlinks/source" 600
