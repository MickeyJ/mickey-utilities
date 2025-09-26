#!/bin/bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Create file with parent directories
# Usage: touchp /path/to/file
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


if [ -z "$1" ]; then
    echo "File not specified... Usage: touchp /path/to/file.txt"
    exit 1
fi

# Create parent directories if they don't exist
mkdir -p "$(dirname "$1")"

# Create the file
touch "$1"