#!/bin/bash
# Remediation: Install apparmor package

set -e

echo "Starting remediation: Installing apparmor package..."

# Check if already installed
if dpkg -l | grep -q "^ii.*apparmor "; then
    echo "apparmor package is already installed"
    exit 0
fi

# Update package list and install apparmor
echo "Installing apparmor..."
apt-get update -qq
apt-get install -y apparmor apparmor-utils

# Verify installation
if dpkg -l | grep -q "^ii.*apparmor "; then
    echo "SUCCESS: apparmor package installed successfully"
    exit 0
else
    echo "ERROR: Failed to install apparmor package"
    exit 1
fi
