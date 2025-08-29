#!/bin/bash

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Function to pretty print directory structure for documentation
# Usage: print_tree <directory> <prefix>
#
# Prerequisites:
#
# $ sh ./create-user-bin.sh
#
# or manually add to ~/bin:
#
# $ cp ./bash-scripts/print-tree.sh ~/bin/print-tree
# $ source ~/.bashrc
#
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

print_tree() {
    local dir="${1:-.}"
    local prefix="${2}"

    # Get all items in directory
    local items=()
    local dirs=()
    local files=()

    # Separate directories and files
    for item in "$dir"/*; do
        [ -e "$item" ] || continue  # Skip if no matches
        if [ -d "$item" ]; then
            dirs+=("$(basename "$item")")
        else
            files+=("$(basename "$item")")
        fi
    done

    # Combine and count items (directories first, then files)
    items=("${dirs[@]}" "${files[@]}")
    local total=${#items[@]}
    local count=0

    # Print each item
    for item in "${items[@]}"; do
        count=$((count + 1))
        local is_last=$([[ $count -eq $total ]] && echo 1 || echo 0)

        # Determine the connector
        if [ $is_last -eq 1 ]; then
            echo "${prefix}└── $item"
            new_prefix="${prefix}    "
        else
            echo "${prefix}├── $item"
            new_prefix="${prefix}│   "
        fi

        # Add trailing slash for directories
        local full_path="$dir/$item"
        if [ -d "$full_path" ]; then
            # Recursively print subdirectories
            print_tree "$full_path" "$new_prefix"
        fi
    done
}

main() {
    local target_dir="${1:-.}"

    # Check if directory exists
    if [ ! -d "$target_dir" ]; then
        echo "Error: '$target_dir' is not a valid directory"
        exit 1
    fi

    # Print the root directory name
    if [ "$target_dir" = "." ]; then
        echo "$(basename "$PWD")/"
    else
        echo "$(basename "$target_dir")/"
    fi

    # Print the tree
    print_tree "$target_dir" ""
}

# Run the script
main "$@"
