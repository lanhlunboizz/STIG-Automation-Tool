#!/bin/bash
# Check if SSH service is enabled and active

enabled_status=$(systemctl is-enabled ssh.service 2>/dev/null || systemctl is-enabled sshd.service 2>/dev/null)
active_status=$(systemctl is-active ssh.service 2>/dev/null || systemctl is-active sshd.service 2>/dev/null)

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "PASS: SSH service is enabled and active"
    exit 0
else
    echo "FAIL: SSH service status - enabled: $enabled_status, active: $active_status"
    exit 1
fi
