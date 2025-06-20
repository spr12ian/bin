#!/usr/bin/env bash
set -euo pipefail

# pwl == Python with logging (don't use .py extension)

if [ $# -eq 0 ]; then
    echo "Python file required"
    exit 1
fi

file=$1
shift # Remove the first argument (the Python file)


#Strip any file extension
python_module="${file%.*}"

log_file="${python_module}".log

error_log_file="${python_module}"_error.log

python3 -m "${python_module}" "$@" >"${log_file}" 2>"${error_log_file}"

# Check if the file exists and its size is zero
if [ -f "$log_file" ] && [ ! -s "$log_file" ]; then
    rm "$log_file"
fi

if [ -f "$error_log_file" ] && [ ! -s "$error_log_file" ]; then
    rm "$error_log_file"
fi
