#!/bin/bash

if [ -f .gitignore ]; then 
  # Check if this is a Git repository
  if [[ ! -d .git ]]; then
    echo "ERROR: Not a Git repository."
    exit 1
  fi

  # echo ".gitignore file exists"

  # Check for staged changes
  staged_changes=$(git diff --cached --name-only)

  if [[ -n $staged_changes ]]; then
    echo "The following files are in the staging area:"
    echo "$staged_changes"

    git rm -r --cached . >/dev/null
    git add .
    git commit -m 'Removed all files that are in the .gitignore' 
    git push origin main
  fi
fi