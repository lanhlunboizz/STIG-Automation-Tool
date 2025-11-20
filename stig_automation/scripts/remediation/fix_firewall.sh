#!/bin/bash
# Remediation: Enable firewall
# Rule: UBTU-24-010009

echo "Enabling UFW firewall..."

# Install UFW if not present
if ! command -v ufw &> /dev/null; then
    apt-get update
    apt-get install -y ufw
fi

# Configure default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH to prevent lockout
ufw allow 22/tcp

# Enable UFW
echo "y" | ufw enable

echo "UFW firewall enabled"
exit 0
