#!/bin/bash
# Remediation: Install libpam-pwquality package

set -e

echo "Starting remediation: Installing libpam-pwquality package..."

# Check if already installed
if dpkg -l | grep -q "^ii.*libpam-pwquality"; then
    echo "libpam-pwquality package is already installed"
    exit 0
fi

# Update package list and install libpam-pwquality
echo "Installing libpam-pwquality..."
apt-get update -qq
apt-get install -y libpam-pwquality

# Verify installation
if dpkg -l | grep -q "^ii.*libpam-pwquality"; then
    echo "SUCCESS: libpam-pwquality package installed successfully"
    exit 0
else
    echo "ERROR: Failed to install libpam-pwquality package"
    exit 1
fi
