``` bash
#!/bin/bash

export GITHUB_PARENT="${HOME}/github-repositories"
export GITHUB_USER_EMAIL="173560+spr12ian@users.noreply.github.com"
export GITHUB_USER_NAME="spr12ian"

ln -s "${GITHUB_PARENT}/bin" "${HOME}/bin"
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

Then run update-linux again, every now and then, to keep your system up to date.

snap is preinstalled on Ubuntu systems, but not yet on ChromeOS Debian so the next step on ChromeOS is

```
install-snap-on-chromeos
```

Now that snap is installed
```
install-snap-packages
```

Every now and then refresh your snap packages
```
sudo snap refresh
```

To do Google App Script (GAS) development locally I use clasp
```
install-clasp
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
