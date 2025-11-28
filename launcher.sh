#!/bin/bash

# Determine the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Execute the Python script using python3
# Ensure python3 is in the path or specify the full path if needed
# You might want to use a specific python environment if you set one up
/Library/Frameworks/Python.framework/Versions/3.11/bin/python3 "$DIR/csv_to_sheets.py" "$@"
