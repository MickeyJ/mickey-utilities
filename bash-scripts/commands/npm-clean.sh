# npm-clean - Deep clean node_modules everywhere
#!/bin/bash
# Usage: npm-clean
echo "Finding all node_modules directories..."
find . -name "node_modules" -type d -prune | while read dir; do
    SIZE=$(du -sh "$dir" | cut -f1)
    echo "  $dir ($SIZE)"
done
read -p "Delete all? (y/N) " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] && find . -name "node_modules" -type d -prune -exec rm -rf {} +