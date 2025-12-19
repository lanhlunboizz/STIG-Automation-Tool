#!/bin/bash
# Remediation: Enable and start sssd service
# DISABLED: This rule causes authentication lockout issues
# TODO: Properly configure SSSD before enabling this

echo "SKIPPED: UBTU-24-100660 remediation disabled to prevent auth lockout"
echo "To manually enable SSSD after proper configuration:"
echo "  1. Configure /etc/sssd/sssd.conf with valid domains"
echo "  2. systemctl enable sssd.service"
echo "  3. systemctl start sssd.service"
exit 0

# Original remediation below (commented out):
# echo "Starting remediation: Enabling and starting sssd.service..."

# Check current status
enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null || echo "disabled")
active_status=$(systemctl is-active sssd.service 2>/dev/null || echo "inactive")

echo "Current status - enabled: $enabled_status, active: $active_status"

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "sssd.service is already enabled and active"
    exit 0
fi

# Check if sssd config exists (basic validation)
if [ -f /etc/sssd/sssd.conf ]; then
    echo "Found /etc/sssd/sssd.conf"
    # Ensure proper permissions
    chmod 600 /etc/sssd/sssd.conf
else
    echo "WARNING: /etc/sssd/sssd.conf not found!"
    echo "Creating minimal configuration..."
    mkdir -p /etc/sssd
    cat > /etc/sssd/sssd.conf <<'EOF'
[sssd]
services = nss, pam
domains = LOCAL

[domain/LOCAL]
id_provider = files
EOF
    chmod 600 /etc/sssd/sssd.conf
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

# Start sssd service
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

# Verify final status
enabled_status=$(systemctl is-enabled sssd.service 2>/dev/null || echo "unknown")
active_status=$(systemctl is-active sssd.service 2>/dev/null || echo "unknown")

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "SUCCESS: sssd.service is now enabled and active"
    exit 0
else
    echo "ERROR: Failed to enable/start sssd.service - enabled: $enabled_status, active: $active_status"
    exit 1
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
