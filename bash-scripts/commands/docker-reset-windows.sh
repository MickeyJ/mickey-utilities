#!/bin/bash

echo "=== DOCKER FORCE RESET SCRIPT ==="

# Function to check if a process is running
check_process() {
    local process_name="$1"
    local count=$(tasklist | grep -i "$process_name" | wc -l)
    echo "$count"
}

# Function to force kill with verification
force_kill_and_verify() {
    local process_name="$1"
    local before=$(check_process "$process_name")

    if [ "$before" -gt 0 ]; then
        echo "Found $before instance(s) of $process_name - killing..."
        taskkill /f /im "$process_name" 2>/dev/null
        sleep 2
        local after=$(check_process "$process_name")
        if [ "$after" -eq 0 ]; then
            echo "✓ Successfully killed $process_name"
        else
            echo "✗ Failed to kill $process_name ($after still running)"
        fi
    else
        echo "- $process_name not running"
    fi
}

echo "Checking Docker processes..."

# Kill all Docker processes with verification
force_kill_and_verify "Docker Desktop.exe"
force_kill_and_verify "dockerd.exe"
force_kill_and_verify "vpnkit.exe"
force_kill_and_verify "com.docker.backend.exe"
force_kill_and_verify "com.docker.vpnkit.exe"

# Nuclear option if anything is still running
echo ""
echo "Checking for any remaining Docker processes..."
docker_processes=$(tasklist | grep -i docker | wc -l)

if [ "$docker_processes" -gt 0 ]; then
    echo "Found $docker_processes Docker processes still running - using nuclear option..."
    wmic process where "name like '%docker%'" delete 2>/dev/null
    sleep 3
    docker_processes_after=$(tasklist | grep -i docker | wc -l)
    echo "Remaining Docker processes: $docker_processes_after"
else
    echo "✓ All Docker processes killed"
fi

echo ""
echo "Waiting 5 seconds before restart..."
sleep 5

echo "Starting Docker Desktop..."
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo "Waiting 10 seconds for Docker to start..."
sleep 10

# Verify Docker Desktop is running
if [ $(check_process "Docker Desktop.exe") -gt 0 ]; then
    echo "✓ Docker Desktop is running"
else
    echo "✗ Docker Desktop failed to start"
fi

echo "=== RESET COMPLETE ==="
