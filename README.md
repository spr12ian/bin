# bin

Shell scripts I keep in my bin folder, some more useful than others.

On a new Linux user login:

export GITHUB_INIT_DEFAULT_BRANCH="Your name"
export GITHUB_USER_EMAIL="Your GitHub unique email address"
export GITHUB_USER_NAME="Your name"

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
Gemini answer: Brackets can be problematic for echo due to their special meaning in shell scripting.

Here's a breakdown of why:

Filename Expansion:

Brackets are often used for filename expansion. For example, echo [a-z] would list all files in the current directory that start with a lowercase letter.   
If you want to print the literal [a-z], you need to escape the brackets or enclose them in quotes.
Command Substitution:

Brackets can also be used for command substitution, which allows you to execute a command within another command and use its output.
If you want to print the literal brackets, you need to escape them or enclose them in quotes.   
To avoid these issues, you can:

Escape the brackets: Use a backslash (\) before each bracket to treat it as a literal character. For example: echo \[a-z\]
Enclose the brackets in quotes: Using single or double quotes will prevent the shell from interpreting the brackets as special characters. For example: echo '[a-z]' or echo "[a-z]"
