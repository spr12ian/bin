#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 1 ]; then
    echo "Too many parameters!"
    exit
fi

if [ $# -eq 0 ]; then # if no arguments provided, prompt user
    echo "What command should I add?"
    read -r command
fi

if [ $# -eq 1 ]; then
    command=$1
fi

cd "${GITHUB_PARENT_DIR}/bin" || exit

if [ -f "$command" ]; then
    touch "$command"
else
    echo '#!/bin/bash' >"$command"
fi

chmod u+x "$command"

git add --chmod=+x "$command"

setup_symbolic_links
