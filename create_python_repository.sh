#!/usr/bin/env bash
set -euo pipefail

if [ $# -eq 1 ]; then
    repo=$1
else
    echo "repo name required"
    exit 1
fi

if ! create_github_repository "${repo}" "Python"; then
    echo "create_github_repository ${repo} Python failed"
    exit 1
fi

repoDirectory="${GITHUB_PARENT_DIR}/${repo}"

cd "${repoDirectory}" || {
    echo cd "${repoDirectory}" failed
    exit 1
}

python3 -m venv venv

source venv/bin/activate

pip install -U pip

pip install pytest

pip freeze >requirements.txt

git add .
git commit -m "Installed venv with pytest"
git push origin

echo "pytest is installed by default on GitHub"

echo "Remember to configure Python in VS Code"
echo " - Open the project folder in VS Code (code ${repoDirectory})."
echo " - Press Ctrl+Shift+P, type **Python: Select Interpreter**, and choose the virtual environment (./venv)."
