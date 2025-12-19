#!/bin/bash
# Remediation: Configure audispd remote logging
# Rule: UBTU-24-100450

echo "Starting remediation: Configuring audispd remote logging..."

AUDISP_REMOTE_CONF="/etc/audisp/plugins.d/au-remote.conf"
AUDISP_CONF="/etc/audisp/audisp-remote.conf"

# Install audispd-plugins if not present
if ! dpkg -l | grep -q "^ii.*audispd-plugins"; then
    echo "Installing audispd-plugins..."
    apt-get update -qq 2>&1 | tail -5
    apt-get install -y audispd-plugins 2>&1 | tail -5
fi

# Backup configs
if [ -f "$AUDISP_REMOTE_CONF" ]; then
    cp "$AUDISP_REMOTE_CONF" "${AUDISP_REMOTE_CONF}.bak.$(date +%Y%m%d_%H%M%S)"
fi

if [ -f "$AUDISP_CONF" ]; then
    cp "$AUDISP_CONF" "${AUDISP_CONF}.bak.$(date +%Y%m%d_%H%M%S)"
fi

# Set active = yes in au-remote.conf
if [ -f "$AUDISP_REMOTE_CONF" ]; then
    sed -i 's/^active = no/active = yes/' "$AUDISP_REMOTE_CONF"
    
    # If line doesn't exist, add it
    if ! grep -q "^active = " "$AUDISP_REMOTE_CONF"; then
        echo "active = yes" >> "$AUDISP_REMOTE_CONF"
    fi
fi

# Configure remote server (use placeholder, admin must set actual IP)
if [ -f "$AUDISP_CONF" ]; then
    # Check if remote_server line exists
    if grep -q "^remote_server = " "$AUDISP_CONF"; then
        echo "remote_server already configured"
    else
        # Add remote_server configuration
        echo "" >> "$AUDISP_CONF"
        echo "# STIG UBTU-24-100450: Remote audit server" >> "$AUDISP_CONF"
        echo "# Replace 192.168.1.100 with actual remote syslog server IP" >> "$AUDISP_CONF"
        echo "remote_server = 192.168.1.100" >> "$AUDISP_CONF"
    fi
fi

# Restart auditd to apply changes
systemctl restart auditd

echo "audispd remote logging configured"
echo "WARNING: Update remote_server IP in $AUDISP_CONF to your actual syslog server"
exit 0
