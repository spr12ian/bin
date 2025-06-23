#!/usr/bin/env bash

# Setting -euo pipefail makes the calling shell brittle if there are any problems in bash_functions
#set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.symlinks/source/bash_functions"

source_if_exists "$HOME/.symlinks/source/bash_functions"

about about

print_path

add_path_if_exists before "$HOME/projects"

print_path

remove_path "$HOME/projects"

print_path

add_path_if_exists "$HOME/projects"

vcode bin

code /tmp/test_bash_functions.log

echo "test_bash_functions completed successfully."
