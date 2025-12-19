#!/bin/bash

# STIG Automation Tool - Sudo Wrapper Script
# Usage: ./run_with_sudo.sh --mode local --auto-remediate

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if virtual environment exists
if [ ! -d "$SCRIPT_DIR/venv" ]; then
    echo "Virtual environment not found. Running quick_start.sh first..."
    bash "$SCRIPT_DIR/quick_start.sh"
fi

# Run with sudo using the venv python
sudo "$SCRIPT_DIR/venv/bin/python3" "$SCRIPT_DIR/main.py" "$@"