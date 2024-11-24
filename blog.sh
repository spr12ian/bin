#!/bin/bash

focus-here.sh

cd "${GITHUB_PARENT}"/spr12ian.github.io  || { echo "ERROR: ${GITHUB_PARENT}/spr12ian.github.io not found"; exit 1; }

new_blog="hugo new blog/$(date -I).md"

$new_blog

code .

hugo server -D &
