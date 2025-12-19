#!/bin/bash
# Remediation: Install chrony package

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo"
    exit 1
fi

echo "Starting remediation: Installing chrony package..."

# Check if already installed
if dpkg -l | grep -q "^ii.*chrony "; then
    echo "chrony package is already installed"
    exit 0
fi

# Update package list and install chrony
echo "Installing chrony..."
apt-get update -qq 2>&1 | tail -5
apt-get install -y chrony 2>&1 | grep -E '(Reading|Building|Unpacking|Setting up|Processing)' | tail -10

# Verify installation
if dpkg -l | grep -q "^ii.*chrony "; then
    echo "SUCCESS: chrony package installed successfully"
    
    # Ensure chrony service is enabled and started
    echo "Enabling and starting chrony service..."
    systemctl enable chrony 2>/dev/null || true
    systemctl start chrony 2>/dev/null || true
    
    # Give service time to start
    sleep 1
    
    # Check if service is running (non-blocking check)
    if systemctl is-active chrony >/dev/null 2>&1; then
        echo "Chrony service started successfully"
    fi
    
    exit 0
else
    echo "ERROR: Failed to install chrony package"
    exit 1
fi
