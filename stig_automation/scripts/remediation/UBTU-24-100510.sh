#!/bin/bash
# Remediation: Configure and enable AppArmor

set -e

echo "Starting remediation: Enabling AppArmor..."

# Check if already enabled
if command -v aa-enabled &>/dev/null && aa-enabled &>/dev/null; then
    echo "AppArmor is already enabled"
    exit 0
fi

# Enable AppArmor service
echo "Enabling AppArmor service..."
systemctl enable apparmor.service
systemctl start apparmor.service

# Wait for service to stabilize
sleep 2

# Verify AppArmor is enabled
if aa-enabled &>/dev/null; then
    echo "SUCCESS: AppArmor is now configured and enabled"
    exit 0
else
    echo "ERROR: Failed to enable AppArmor"
    exit 1
fi
