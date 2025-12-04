#!/bin/bash
# Remediation: Install UFW
# Rule: UBTU-24-100300

echo "Installing UFW..."

apt-get update
apt-get install -y ufw

if command -v ufw &> /dev/null; then
    echo "UFW installed successfully"
    exit 0
else
    echo "ERROR: Failed to install UFW"
    exit 1
fi
