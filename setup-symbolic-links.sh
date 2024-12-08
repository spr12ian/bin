#!/bin/bash

source_dir="${GITHUB_PARENT}"/bin
target_dir="$HOME/.local/bin"
mkdir -p "${target_dir}"

# Find all .sh files in the source directory
files=$(ls "${source_dir}"/*.sh)
echo "${files}"

for file in ${files}; do
    echo "${file}"
    #Strip .sh file extension
    command_file=$(basename "${file%.*}")
    echo "${command_file}"
    ln -s "${file}" "${target_dir}/${command_file}"
done

ls -al "${target_dir}"
