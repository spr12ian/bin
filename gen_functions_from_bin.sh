#!/bin/bash
# Generates Bash functions for each .sh script in a directory

SRC_DIR="$HOME/projects/bin"                     # folder with .sh scripts
OUT_FILE="$HOME/.bash_local/functions.sh"        # where to write the functions
mkdir -p "$(dirname "$OUT_FILE")"                # ensure output dir exists

echo "# Auto-generated functions from $SRC_DIR" > "$OUT_FILE"
echo "# Regenerate with: bash gen_functions_from_bin.sh" >> "$OUT_FILE"
echo "" >> "$OUT_FILE"

for script in "$SRC_DIR"/*.sh; do
    # Skip non-files (in case of glob failure)
    [ -f "$script" ] || continue

    name=$(basename "$script" .sh)

    # Skip invalid names (e.g. ones that would clash with builtins)
    if [[ ! "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        echo "Skipping invalid function name: $name"
        continue
    fi

    echo "function $name() {" >> "$OUT_FILE"
    echo "  bash \"$script\" \"\$@\"" >> "$OUT_FILE"
    echo "}" >> "$OUT_FILE"
    echo "" >> "$OUT_FILE"
done

echo "Generated functions for scripts in $SRC_DIR -> $OUT_FILE"
