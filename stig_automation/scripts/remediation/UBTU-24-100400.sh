#!/bin/bash
# Remediation: Install auditd
# Rule: UBTU-24-100400

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo"
    exit 1
fi

echo "Installing auditd..."

# Check if already installed
if command -v auditd &> /dev/null; then
    echo "auditd already installed"
    exit 0
fi

echo "Installing auditd and audispd-plugins packages..."
apt-get update -qq 2>&1 | tail -5
DEBIAN_FRONTEND=noninteractive apt-get install -y auditd audispd-plugins 2>&1 | grep -E '(unpacking|Setting up)' | tail -5

if command -v auditd &> /dev/null; then
    echo "SUCCESS: auditd installed"
    exit 0
else
    echo "ERROR: Failed to install auditd"
    exit 1
fi
