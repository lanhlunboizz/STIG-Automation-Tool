#!/bin/bash
# Remediation: Configure audispd remote logging
# Rule: UBTU-24-100450

echo "Starting remediation: Configuring audispd remote logging..."

# Function to wait for dpkg lock
wait_for_lock() {
    local max_wait=60
    local waited=0
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        if [ $waited -ge $max_wait ]; then
            echo "WARNING: dpkg lock timeout"
            return 1
        fi
        sleep 3
        waited=$((waited + 3))
    done
    return 0
}

AUDISP_REMOTE_CONF="/etc/audisp/plugins.d/au-remote.conf"
AUDISP_CONF="/etc/audisp/audisp-remote.conf"

# Check for Ubuntu 24.04 path
if [ ! -f "$AUDISP_CONF" ]; then
    AUDISP_CONF="/etc/audit/audisp-remote.conf"
fi

# Install audispd-plugins if not present
if ! dpkg -l | grep -q "^ii.*audispd-plugins"; then
    echo "Installing audispd-plugins..."
    wait_for_lock
    apt-get update -qq 2>&1 | tail -3
    
    wait_for_lock
    DEBIAN_FRONTEND=noninteractive apt-get install -y audispd-plugins 2>&1 | tail -5
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

# Configure remote server with a valid example IP (organization should change this)
# Using 10.0.0.1 as a valid private network IP placeholder
REMOTE_SYSLOG_IP="10.0.0.1"

if [ -f "$AUDISP_CONF" ]; then
    # Update or add remote_server configuration
    if grep -qi "^remote_server" "$AUDISP_CONF"; then
        sed -i "s/^remote_server.*/remote_server = $REMOTE_SYSLOG_IP/" "$AUDISP_CONF"
    else
        echo "" >> "$AUDISP_CONF"
        echo "# STIG UBTU-24-100450: Remote audit server" >> "$AUDISP_CONF"
        echo "remote_server = $REMOTE_SYSLOG_IP" >> "$AUDISP_CONF"
    fi
fi

# Restart auditd to apply changes
systemctl restart auditd 2>/dev/null || true

echo "audispd remote logging configured to $REMOTE_SYSLOG_IP"
echo "WARNING: Update remote_server IP in $AUDISP_CONF to your actual syslog server"
exit 0
