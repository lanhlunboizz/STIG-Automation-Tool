#!/bin/bash
# Remediation: Enable and start sssd service

set -e

echo "Starting remediation: Enabling sssd.service..."

# Check if service is already enabled and active
enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null || echo "disabled")
active_status=$(systemctl is-active sssd.service 2>/dev/null || echo "inactive")

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "sssd.service is already enabled and active"
    exit 0
fi

# Enable and start sssd service
echo "Enabling and starting sssd.service..."
systemctl enable sssd.service
systemctl start sssd.service

# Wait for service to stabilize
sleep 2

# Verify service status
enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null)
active_status=$(systemctl is-active sssd.service 2>/dev/null)

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "SUCCESS: sssd.service is now enabled and active"
    exit 0
else
    echo "ERROR: Failed to enable/start sssd.service - enabled: $enabled_status, active: $active_status"
    exit 1
fi
