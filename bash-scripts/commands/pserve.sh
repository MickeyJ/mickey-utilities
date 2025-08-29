#!/bin/bash
# pserve - Start HTTP server with optional path and auto-open browser
# Usage: pserve [path] [port]

# Parse arguments - if first arg is a number, it's the port
if [[ "$1" =~ ^[0-9]+$ ]]; then
    DIR="."
    PORT=$1
else
    DIR="${1:-.}"
    PORT="${2:-8000}"
fi

# Check if directory exists
if [ ! -d "$DIR" ]; then
    echo "Error: Directory '$DIR' does not exist"
    exit 1
fi

# Get absolute path for display
ABS_PATH=$(cd "$DIR" && pwd)

echo "🚀 Starting server..."
echo "📁 Serving: $ABS_PATH"
echo "🌐 URL: http://localhost:$PORT"
echo ""

# Open browser (works on Windows Git Bash, Mac, and Linux)
if command -v start &> /dev/null; then
    # Windows Git Bash
    (sleep 1 && start "http://localhost:$PORT") &
elif command -v open &> /dev/null; then
    # macOS
    (sleep 1 && open "http://localhost:$PORT") &
elif command -v xdg-open &> /dev/null; then
    # Linux
    (sleep 1 && xdg-open "http://localhost:$PORT") &
fi

# Start the server
cd "$DIR" && python -m http.server $PORT