#!/bin/bash

(return 0 2>/dev/null) && __SCRIPT_SOURCED=1 || __SCRIPT_SOURCED=0

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/stackframe.sh"

next="b.sh"

echo "Running ${BASH_SOURCE[0]} (Depth=$DEPTH, Sourced=$__SCRIPT_SOURCED)"
echo "Call stack: ${CALL_STACK//|/ -> }"

if [ "$__SCRIPT_SOURCED" -eq 1 ]; then
    echo "I was sourced. Executing $next"
    bash "$next"
else
    echo "I was executed. Sourcing $next"
    # shellcheck source=/dev/null
    source "$next"
fi

if [ "$__SCRIPT_SOURCED" -eq 1 ]; then
    export DEPTH=$((DEPTH - 1))
    export CALL_STACK="${CALL_STACK%|*}"
fi
