#!/bin/bash
# Remediation: Enable and start sssd service

echo "Starting remediation: Enabling sssd.service..."

# Check if service is already enabled and active
enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null || echo "disabled")
active_status=$(systemctl is-active sssd.service 2>/dev/null || echo "inactive")

echo "Current status - enabled: $enabled_status, active: $active_status"

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "sssd.service is already enabled and active"
    exit 0
fi

# Enable sssd service
if [ "$enabled_status" != "enabled" ]; then
    echo "Enabling sssd.service..."
    if systemctl enable sssd.service 2>&1; then
        echo "Successfully enabled sssd.service"
    else
        echo "Failed to enable sssd.service"
        exit 1
    fi
fi

# Start sssd service if not active
if [ "$active_status" != "active" ]; then
    echo "Starting sssd.service..."
    if systemctl start sssd.service 2>&1; then
        echo "Successfully started sssd.service"
    else
        echo "Failed to start sssd.service"
        exit 1
    fi
fi

# Wait for service to stabilize
sleep 2

# Verify service status
enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null || echo "unknown")
active_status=$(systemctl is-active sssd.service 2>/dev/null || echo "unknown")

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "SUCCESS: sssd.service is now enabled and active"
    exit 0
else
    echo "ERROR: Failed to enable/start sssd.service - enabled: $enabled_status, active: $active_status"
    exit 1
fi
