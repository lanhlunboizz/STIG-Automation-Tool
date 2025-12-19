#!/bin/bash
# Remediation: Install and initialize AIDE
# Rule: UBTU-24-010007

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo"
    exit 1
fi

echo "Installing AIDE..."

# Check if already installed
if command -v aide &> /dev/null; then
    echo "AIDE already installed"
    exit 0
fi

# Install AIDE
echo "Installing aide and aide-common packages..."
apt-get update -qq 2>&1 | tail -5
DEBIAN_FRONTEND=noninteractive apt-get install -y aide aide-common 2>&1 | grep -E '(unpacking|Setting up)' | tail -5

# Verify installation
if command -v aide &> /dev/null; then
    echo "SUCCESS: AIDE installed"
    exit 0
else
    echo "ERROR: AIDE installation failed"
    exit 1
fi


