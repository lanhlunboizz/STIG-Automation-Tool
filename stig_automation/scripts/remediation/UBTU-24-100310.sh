#!/bin/bash
# Remediation: Enable UFW
# Rule: UBTU-24-100310

echo "Enabling UFW..."

if ! command -v ufw &> /dev/null; then
    echo "ERROR: UFW is not installed"
    exit 1
fi

# Configure default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH to prevent lockout
ufw allow 22/tcp

# Enable UFW (non-interactive)
echo "y" | ufw enable

# Verify
if ufw status | grep -q "Status: active"; then
    echo "UFW enabled successfully"
    exit 0
else
    echo "ERROR: Failed to enable UFW"
    exit 1
fi
