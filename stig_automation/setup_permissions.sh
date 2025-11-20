#!/bin/bash
# Make all scripts executable

echo "Setting execute permissions for all scripts..."

# Check scripts
chmod +x scripts/checks/*.sh

# Remediation scripts
chmod +x scripts/remediation/*.sh

echo "✓ All scripts are now executable"
