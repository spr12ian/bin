#!/bin/bash

if [ "$DEBUG" = "true" ]; then
    "$@"
else
    "$@" &>/dev/null
fi
