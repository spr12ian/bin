#!/bin/bash

# pwl == Python with logging (don't use .py extension)

if [ $# -eq 0 ]; then
    echo "Python file required"
    exit 1
fi

file=$1

#Strip any file extension
python_file="${file%.*}"

log_file="${python_file}".log
error_log_file="${python_file}"_error.log

args="$*"
python3 -m "${args}" >"${log_file}" 2>"${error_log_file}"

# Check if the file exists and its size is zero
if [ -f "$log_file" ] && [ ! -s "$log_file" ]; then
    rm "$log_file"
fi

if [ -f "$error_log_file" ] && [ ! -s "$error_log_file" ]; then
    rm "$error_log_file"
fi
