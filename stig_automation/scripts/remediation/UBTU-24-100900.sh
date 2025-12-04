#!/bin/bash
# Remediation: Install opensc-pkcs11 package for PIV/CAC support

echo "Starting remediation: Installing opensc-pkcs11 package..."

# Check if already installed
if dpkg -l | grep -q "^ii.*opensc-pkcs11"; then
    echo "opensc-pkcs11 package is already installed"
    exit 0
fi

# Update package list and install opensc-pkcs11
echo "Installing opensc-pkcs11..."
apt-get update -qq
apt-get install -y opensc-pkcs11

# Verify installation
if dpkg -l | grep -q "^ii.*opensc-pkcs11"; then
    echo "SUCCESS: opensc-pkcs11 package installed successfully"
    exit 0
else
    echo "ERROR: Failed to install opensc-pkcs11 package"
    exit 1
fi
