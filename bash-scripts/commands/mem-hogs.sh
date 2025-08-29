# mem-hogs - Find memory-hungry processes
#!/bin/bash
# Usage: mem-hogs
ps aux | awk 'NR>1 {printf "%-10s %-8s %s\n", $2, $4"%", $11}' | \
    sort -k2 -rn | head -10