#!/bin/bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Open file in nano with parent directories created
# Usage: nanop /path/to/file
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


if [ -z "$1" ]; then
    echo "File not specified... Usage: nanop /path/to/file"
    exit 1
fi

# Create parent directories if they don't exist
mkdir -p "$(dirname "$1")"

# Open nano with the file
nano "$1"