#!/bin/bash

# Determine the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Downloaded files carry a quarantine flag that blocks Automator from opening them.
for file in "$@"; do
    if [[ -f "$file" ]]; then
        xattr -d com.apple.quarantine "$file" 2>/dev/null || true
    fi
done

"$DIR/.venv/bin/python3" "$DIR/csv_to_sheets.py" "$@"
