#!/usr/bin/env bash
set -euo pipefail

if [ -d "$HOME/.asdf" ]; then
  echo "✅ Already installed: asdf..."
else
  echo "✅ Installing asdf..."
  # After v0.14.0 it gets complicated
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
fi

asdf --version

# Import Node.js release team's GPG keys (essential step)
echo "✅ Importing GPG keys..."
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

# Then install Node.js
echo "✅ Installing Node.js..."
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest
