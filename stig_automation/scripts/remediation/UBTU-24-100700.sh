#!/bin/bash
# Remediation: Install chrony package

echo "Starting remediation: Installing chrony package..."

# Check if already installed
if dpkg -l | grep -q "^ii.*chrony "; then
    echo "chrony package is already installed"
    exit 0
fi

# Update package list and install chrony
echo "Installing chrony..."
apt-get update -qq
apt-get install -y chrony

# Verify installation
if dpkg -l | grep -q "^ii.*chrony "; then
    echo "SUCCESS: chrony package installed successfully"
    
    # Ensure chrony service is enabled and started
    systemctl enable chrony 2>&1
    systemctl start chrony 2>&1
    
    exit 0
else
    echo "ERROR: Failed to install chrony package"
    exit 1
fi
