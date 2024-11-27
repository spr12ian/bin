#!/bin/bash

if [ $# -eq 1 ]; then
    repo=$1
else
    echo "repo name required"
    exit 1
fi

if ! create-github-repository.sh "${repo}" "Python"; then
    echo "create-github-repository.sh ${repo} Python failed"
    exit 1
fi

repoDirectory="${GITHUB_PARENT}/${repo}"

cd "${repoDirectory}" || {
    echo cd "${repoDirectory}" failed
    exit 1
}

python3 -m venv venv

source venv/bin/activate

pip install flask
pip install django

pip freeze >requirements.txt

git add .
git commit -m "Installed venv with flask and django"
git push origin

echo "pytest is installed by default on GitHub"

echo "Remember to configure Python in VS Code"
echo " - Open the project folder in VS Code (code ${repoDirectory})."
echo " - Press Ctrl+Shift+P, type **Python: Select Interpreter**, and choose the virtual environment (./venv)."