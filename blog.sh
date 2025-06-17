#!/bin/bash
set -euo pipefail

focus-here

cd "${GITHUB_PARENT}/${GITHUB_USER_NAME}.github.io" || {
    echo "ERROR: ${GITHUB_PARENT}/${GITHUB_USER_NAME}.github.io not found"
    exit 1
}

new_blog="hugo new blog/$(date -I).md"

$new_blog

code .

hugo server -D &
