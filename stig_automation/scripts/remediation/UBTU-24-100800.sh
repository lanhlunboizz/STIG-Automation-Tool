#!/bin/bash
# Remediation: Install SSH meta-package

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo"
    exit 1
fi

echo "Starting remediation: Installing ssh meta-package..."

# Check if all required packages are already installed
if dpkg -l | grep -q "^ii.*openssh-client" && \
   dpkg -l | grep -q "^ii.*openssh-server" && \
   dpkg -l | grep -q "^ii.*openssh-sftp-server"; then
    echo "All openssh packages are already installed"
    exit 0
fi

# Update package list and install ssh meta-package
# This will install openssh-client, openssh-server, and openssh-sftp-server
echo "Installing ssh meta-package..."
apt-get update -qq 2>&1 | tail -5
apt-get install -y ssh 2>&1 | grep -E '(Reading|Building|Unpacking|Setting up|Processing)' | tail -10

# Verify installation
if dpkg -l | grep -q "^ii.*openssh-client" && \
   dpkg -l | grep -q "^ii.*openssh-server" && \
   dpkg -l | grep -q "^ii.*openssh-sftp-server"; then
    echo "SUCCESS: ssh meta-package installed successfully"
    echo "Installed: openssh-client, openssh-server, openssh-sftp-server"
    exit 0
else
    echo "ERROR: Failed to install all required openssh packages"
    exit 1
fi
