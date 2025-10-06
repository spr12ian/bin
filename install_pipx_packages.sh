#!/usr/bin/env bash
set -euo pipefail

pipx upgrade codespell || pipx install codespell && codespell --version
pipx upgrade hatch || pipx install hatch && hatch --version
pipx upgrade mypy || pipx install mypy && mypy --version
pipx upgrade ruff || pipx install ruff && ruff --version


