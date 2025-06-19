#!/usr/bin/env bash
set -euo pipefail

clear
echo $#
if [ $# -eq 0 ]; then     # if no arguments provided, prompt user
    echo -n "What commands are you asking about?> "
    read -r args
else
    args=$*
fi

for cmd in $args  # for each command entered
do
    echo "$cmd"
    echo -n "executable: "
    which "$cmd"
    echo -n "all files: "
    whereis "$cmd"
    echo "functions:"
    whatis "$cmd"
    echo "===================================================================="
done
