#!/bin/bash

# BFG Repo-Cleaner https://rtyley.github.io/bfg-repo-cleaner/

if [ $# -gt 2 ]; then
    echo Too many parameters!
    exit
fi

workFolder=~/bfg-work-folder
echo BFG Work folder: $workFolder

if [ $# -eq 2 ]; then
    echo $1 $2
    case $1 in
    setup)
        if [ ! -d $workFolder ]; then
            mkdir $workFolder
        fi
        cd $workFolder
        git clone --mirror https://github.com/spr12ian/$2.git
        ;;
    *)
        echo 'Invalid command: ' $1 $2
        ;;
    esac
    exit
fi

if [ $# -eq 1 ]; then
    command=$1
    case $1 in
    cleardown)
        echo cleardown
        rm -rf $workFolder
        ;;
    *)
        echo 'Invalid command: ' $1
        ;;
    esac
    exit
fi

if [ ! -d $workFolder ]; then
    echo $workFolder does NOT exist
    exit
fi

cd $workFolder
pwd
