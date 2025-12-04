#!/bin/bash
# Remediation: Install OpenSSH server

echo "Starting remediation: Installing openssh-server..."

# Check if already installed
if dpkg -l | grep -q "^ii.*openssh-server"; then
    echo "openssh-server package is already installed"
    exit 0
fi

# Update package list and install openssh-server
echo "Installing openssh-server..."
apt-get update -qq
apt-get install -y openssh-server

# Verify installation
if dpkg -l | grep -q "^ii.*openssh-server"; then
    echo "SUCCESS: openssh-server installed successfully"
    exit 0
else
    echo "ERROR: Failed to install openssh-server"
    exit 1
fi
