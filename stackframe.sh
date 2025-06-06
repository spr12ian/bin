#!/bin/bash

# stackframe.sh

: "${MAX_DEPTH:=12}"
: "${DEPTH:=0}"
: "${CALL_STACK:=}"

echo "1: $CALL_STACK"

__CURRENT_SCRIPT="$(basename "${BASH_SOURCE[1]}")"
echo "2: $__CURRENT_SCRIPT"

# Always push current script
CALL_STACK="${CALL_STACK:+${CALL_STACK}|}${__CURRENT_SCRIPT}"
echo "3: $CALL_STACK"
DEPTH=$((DEPTH + 1))

export CALL_STACK DEPTH MAX_DEPTH

if [ "$DEPTH" -gt "$MAX_DEPTH" ]; then
    echo "ERROR: Maximum depth ($MAX_DEPTH) exceeded at $__CURRENT_SCRIPT"
    echo "Call stack: ${CALL_STACK//|/ -> }"
    exit 1
fi

if [ "${DEBUG:-0}" -eq 1 ]; then
    echo "Running $__CURRENT_SCRIPT (Depth=$DEPTH)"
    echo "Call stack: ${CALL_STACK//|/ -> }"
fi
