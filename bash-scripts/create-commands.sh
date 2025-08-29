#!/bin/bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# create-user-bin.sh
# What it does:
# - Create user '~/bin' directory,
# - adds '~/bin' to PATH,
# - creates symlinks for all commands in ./commands directory
#
# Usage: sh ./create-user-bin.sh
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

export MSYS=winsymlinks:nativestrict

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/bin

# Add ~/bin to PATH if not already present
if [[ ":$PATH:" != *":$HOME/bin:"* ]] && ! grep -q '$HOME/bin' ~/.bashrc; then
    echo "Adding ~/bin to PATH in .bashrc"
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

# Create symlinks for all commands in ./commands directory
for file in "$SCRIPT_DIR"/commands/*; do
    if [ -f "$file" ]; then
        command=$(basename "$file" .sh)
        absolute_path="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
        [ -f ~/bin/$command ] && rm ~/bin/$command
        if output=$(ln -sf "$absolute_path" ~/bin/"$command" 2>&1); then
            echo "✓ Created $command"
        elif [[ "$output" == *"Operation not permitted"* ]]; then
            echo "⚠ Need admin rights - run Git Bash as Administrator or use sudo"
            exit 1
        fi
    fi
done
source ~/.bashrc