# bin

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

## To Do

Why are brackets a problem for echo in the about script?
