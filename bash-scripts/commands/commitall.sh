#!/bin/bash
# commitall - Add all files and commit with message
# Usage: commitall your commit message here

if [ $# -eq 0 ]; then
    echo "Usage: commitall your commit message here"
    exit 1
fi

git add .
git commit -m "$*"