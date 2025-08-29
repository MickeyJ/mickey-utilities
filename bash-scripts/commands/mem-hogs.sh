#!/bin/bash
# mem-hogs - Cross-platform memory usage monitor
# Usage: mem-hogs [count]

COUNT=${1:-10}

# Function for Windows (Git Bash)
mem_hogs_windows() {
    local count=$1

    echo "================================================================="
    printf "%-30s %10s %15s\n" "PROCESS" "PID" "MEMORY"
    echo "================================================================="

    # Use Windows tasklist command
    tasklist //FO CSV 2>/dev/null | awk -F'","' -v count=$count '
    NR>1 {
        # Remove quotes from first and last field
        gsub(/^"/, "", $1)
        gsub(/"$/, "", $5)

        # Extract process name
        process = $1
        gsub(/\.exe$/, "", process)
        if (length(process) > 28) process = substr(process, 1, 25) "..."

        # Extract PID
        pid = $2

        # Extract and format memory (it comes as "1,234 K")
        mem_str = $5
        gsub(/[, ]/, "", mem_str)  # Remove commas and spaces
        gsub(/K$/, "", mem_str)    # Remove K suffix

        if (mem_str ~ /^[0-9]+$/) {
            mem_kb = int(mem_str)

            # Convert to appropriate unit
            if (mem_kb > 1048576) {
                mem_display = sprintf("%.1f GB", mem_kb/1048576)
            } else if (mem_kb > 1024) {
                mem_display = sprintf("%.0f MB", mem_kb/1024)
            } else {
                mem_display = sprintf("%d KB", mem_kb)
            }

            # Store for sorting
            memory[NR] = mem_kb
            lines[NR] = sprintf("%-30s %10s %15s", process, pid, mem_display)
        }
    }
    END {
        # Sort by memory and print top N
        PROCINFO["sorted_in"] = "@val_num_desc"
        i = 0
        for (idx in memory) {
            if (++i <= count) print lines[idx]
        }
    }'

    echo "================================================================="

    # Show Windows system memory
    echo ""
    local total_kb=$(wmic OS get TotalVisibleMemorySize //value 2>/dev/null | grep = | cut -d= -f2 | tr -d '\r')
    local free_kb=$(wmic OS get FreePhysicalMemory //value 2>/dev/null | grep = | cut -d= -f2 | tr -d '\r')

    if [ -n "$total_kb" ] && [ -n "$free_kb" ]; then
        local used_kb=$((total_kb - free_kb))
        local percent=$((used_kb * 100 / total_kb))
        local total_gb=$((total_kb / 1048576))
        local used_gb=$((used_kb / 1048576))
        echo "System Memory: ${used_gb}GB / ${total_gb}GB ($percent% used)"
    fi
}

# Function for Linux/Unix/Mac
mem_hogs_unix() {
    local count=$1

    echo "================================================================="
    printf "%-30s %8s %7s %7s %10s\n" "PROCESS" "PID" "CPU%" "MEM%" "MEMORY"
    echo "================================================================="

    ps aux | awk -v count=$count '
    NR>1 {
        # Extract process name
        cmd = $11
        gsub(/.*\//, "", cmd)  # Remove path
        if (length(cmd) > 28) cmd = substr(cmd, 1, 25) "..."

        # Calculate memory in MB (RSS is in KB)
        mem_mb = $6/1024

        # Format memory with appropriate unit
        if (mem_mb > 1024) {
            mem_str = sprintf("%.1f GB", mem_mb/1024)
        } else {
            mem_str = sprintf("%.0f MB", mem_mb)
        }

        # Color codes for memory usage
        color = ""
        reset = "\033[0m"
        if ($4 > 20) color = "\033[31m"  # Red for >20%
        else if ($4 > 10) color = "\033[33m"  # Yellow for >10%
        else color = "\033[32m"  # Green for <10%

        printf "%s%-30s %8s %6.1f%% %6.1f%% %10s%s\n",
               color, cmd, $2, $3, $4, mem_str, reset
    }' | sort -k4 -rn | head -$count

    echo "================================================================="

    # Show Unix/Linux system memory
    echo ""
    if command -v free &> /dev/null; then
        # Linux
        free -h | grep "^Mem:" | awk '{
            printf "System Memory: %s / %s (", $3, $2
        }'
        free | grep "^Mem:" | awk '{
            printf "%.0f%% used)\n", ($3/$2)*100
        }'
    elif command -v vm_stat &> /dev/null; then
        # macOS
        vm_stat | awk '
        /Pages free/ {free=$3}
        /Pages active/ {active=$3}
        /Pages inactive/ {inactive=$3}
        /Pages speculative/ {spec=$3}
        /Pages wired/ {wired=$3}
        END {
            total = (free + active + inactive + spec + wired) * 4096 / 1048576 / 1024
            used = (active + wired) * 4096 / 1048576 / 1024
            printf "System Memory: %.1fGB / %.1fGB (%.0f%% used)\n", used, total, (used/total)*100
        }'
    fi
}

# Detect OS and run appropriate function
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash, Cygwin, etc.)
    mem_hogs_windows $COUNT
elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "freebsd"* ]]; then
    # Linux, macOS, or BSD
    mem_hogs_unix $COUNT
else
    # Fallback - try to detect by checking for Windows commands
    if command -v tasklist &> /dev/null; then
        mem_hogs_windows $COUNT
    else
        mem_hogs_unix $COUNT
    fi
fi