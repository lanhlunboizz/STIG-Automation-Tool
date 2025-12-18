#!/bin/bash
# Make all scripts executable

echo "Setting execute permissions for all scripts..."

# Check scripts
chmod +x scripts/checks/*.sh

# Remediation scripts
chmod +x scripts/remediation/*.sh

chmod +x run_with_sudo.sh
chmod +x quick_start.sh
chmod +x main.py

echo "✓ All scripts are now executable"
