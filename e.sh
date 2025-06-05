#!/bin/bash
next="a.sh"
echo "I am ${BASH_SOURCE[0]}"
(return 0 2>/dev/null) && __SCRIPT_SOURCED=1 || __SCRIPT_SOURCED=0
if [ "$__SCRIPT_SOURCED" -eq 1 ]; then
    echo "I was sourced"
    bash $next
else
    echo "I was executed"
    # shellcheck source=/dev/null
    source $next
fi
