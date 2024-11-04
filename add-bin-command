#!/bin/bash

if [ $# -gt 1 ]; then
    echo “Too many parameters!“
    exit
fi

if [ $# -eq 0 ]; then     # if no arguments provided, prompt user
    echo “What command should I add?“
    read command
fi

if [ $# -eq 1 ]; then
    command=$1
fi

cd ~/bin

if [ -f $command ]; then
    touch $command
else
    echo '#!/bin/bash' > $command
fi

chmod u+x $command

git add --chmod=+x $command