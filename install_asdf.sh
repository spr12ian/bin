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

# Add Node.js plugin if not already added
if asdf plugin list | grep -q "^nodejs$"; then
  echo "✅ Node.js plugin already added..."
else
  echo "✅ Adding Node.js plugin..."
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
fi

# Then install Node.js
echo "✅ Installing Node.js..."
asdf install nodejs latest
asdf global nodejs latest

node --version
