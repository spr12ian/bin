#!/bin/bash

clear
echo $#
if [ $# -eq 0 ]; then     # if no arguments provided, prompt user
    echo -n “What commands are you asking about?> “
    read args
else
    args=$*
fi

for cmd in `echo $args`  # for each command entered
do
    echo “$cmd”
    echo -n “executable: “
    which $cmd
    echo -n “all files: “
    whereis $cmd
    echo “functions:”
    whatis $cmd
    echo “====================================================================”
done