#!/bin/bash

focus-here.sh

cd ~/${GITHUB_PARENT}/spr12ian.github.io

new_blog="hugo new blog/`date -I`.md"

$new_blog

code .

hugo server -D &
