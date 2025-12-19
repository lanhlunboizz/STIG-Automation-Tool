#!/bin/bash
# Check if sssd service is enabled and active
# Per STIG: Verify sssd.service is enabled and active

enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null)
active_status=$(systemctl is-active sssd.service 2>/dev/null)

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "PASS: sssd.service is enabled and active"
    exit 0
else
    echo "FAIL: sssd.service status - enabled: $enabled_status, active: $active_status"
    exit 1
fi
