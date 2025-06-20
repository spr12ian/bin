# bin

Shell scripts I keep in my bin folder, some more useful than others.

## First steps in a new Linux bash environment

Manually run these commands:

```
# Setup the GitHub environment variables
export GITHUB_INIT_DEFAULT_BRANCH="main"
export GITHUB_USER_EMAIL="Your GitHub unique email address"
export GITHUB_USER_NAME="Your GitHub user name"

# Install the GitHub CLI (gh)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Authorise gh
gh auth login
# Where do you use Github? Accept default of GitHub.com
# What is your preferred protocol for Git operations on this host? Use SSH
# Upload your SSH public key to your GitHub account? Accept default of ~/.ssh/id_ed25519.pub
# Title for your SSH key: Accept default of (GitHub CLI)
# How would you like to authenticate GitHub CLI?

gh repo clone "${GITHUB_USER_NAME}"/bin

focus_here
```



snap is preinstalled on Ubuntu systems, but not yet on ChromeOS Debian so the next step on ChromeOS is

```
install_snap_on_chromeos
```

Now that snap is installed
```
install_snap_packages
```

Every now and then refresh your snap packages
```
sudo snap refresh
```

## How this repo was created

On a new Linux user login:

mkdir ~/bin
cd ~/bin

chmod u+x *
chmod u-x README.md

git init
git add .
git update-index --chmod=+x *
git update-index --chmod=-x README.md

## To Do

## trap
# enable
trap 'echo "Executing: $BASH_COMMAND"' DEBUG
# disable
trap - DEBUG

sudo apt-get install shellcheck

``` bash
#!/bin/bash


mkdir -p ~/.local
ln -s "${GITHUB_PARENT}"/bin ~/.local/bin
```

if [ -d ~/bin ]; then
 echo folder ~/bin already exists
 else
 mkdir ~/bin
 echo folder ~/bin created
fi

exit
return

Shell scripts I keep in my bin folder, some more useful than others.

On a new Linux user login:

```
mkdir ~/bin
cd ~/bin
update-linux
```

Then run update_linux again, every now and then, to keep your system up to date.

snap is preinstalled on Ubuntu systems, but not yet on ChromeOS Debian so the next step on ChromeOS is

```
install_snap_on_chromeos
```

Now that snap is installed
```
install_snap_packages
```

Every now and then refresh your snap packages
```
sudo snap refresh
```

To do Google App Script (GAS) development locally I use clasp
```
install_clasp
```

## How this repo was created

On a new Linux user login:

mkdir ~/bin
cd ~/bin

chmod u+x *
chmod u-x README.md

git init
git add .
git update-index --chmod=+x *
git update-index --chmod=-x README.md
