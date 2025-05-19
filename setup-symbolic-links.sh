#!/bin/bash

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
    echo "Processing: ${file}"

    # Check if file has a shebang line
    grep -q '^#!' "$file" || echo "WARNING: $file is missing a shebang line"
    [[ ! -f "${file}" ]] && echo "Source is not a regular file"
    [[ ! -x "${file}" ]] && echo "Source is not executable"
    
    command_file=$(basename "${file}" .sh)
    link_path="${target_dir}/${command_file}"

    ln -sf "${file}" "${link_path}"
    echo "Created symlink: ${link_path} -> ${file}"

    [[ ! -x "${link_path}" ]] && echo "Link is not executable"
    [[ ! -f "${link_path}" ]] && echo "Link is not a regular file"

    echo
done

ls -al "${target_dir}"
echo "Symbolic links created in ${target_dir} for all .sh files in ${source_dir}"
echo "Please add ${target_dir} to your PATH if not already done."
echo "Done."
echo "Please run the following command to add ${target_dir} to your PATH:"
echo "export PATH=\"${target_dir}:\$PATH\""
echo "You can add this line to your ~/.bashrc or ~/.bash_profile to make it permanent."
echo "You can also add the following line to your ~/.profile to make it permanent:"
echo "export PATH=\"${target_dir}:\$PATH\""
echo "You can also add the following line to your ~/.bash_profile to make it permanent:"
echo "export PATH=\"${target_dir}:\$PATH\""
echo "You can also add the following line to your ~/.bashrc to make it permanent:"
echo "export PATH=\"${target_dir}:\$PATH\""