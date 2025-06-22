#!/usr/bin/env bash

# Setting -euo pipefail makes the calling shell brittle if there are any problems in bash_functions
#set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.symlinks/source/bash_functions"

about about

echo "test_bash_functions completed successfully."
