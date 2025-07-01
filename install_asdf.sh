#!/usr/bin/env bash
set -euo pipefail

if [ -d "$HOME/.asdf" ]; then
  git -C ~/.asdf pull
else
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.18.0
fi

asdf --version






# Import Node.js release team's GPG keys (essential step)
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring


# Then install Node.js
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest
