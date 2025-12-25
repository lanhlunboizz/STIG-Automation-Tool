#!/bin/bash
# Check: audispd remote logging configured
# Rule: UBTU-24-100450

AUDISP_REMOTE_CONF="/etc/audisp/plugins.d/au-remote.conf"
AUDISP_CONF="/etc/audisp/audisp-remote.conf"

# Check new path for Ubuntu 24.04
if [ ! -f "$AUDISP_CONF" ]; then
    AUDISP_CONF="/etc/audit/audisp-remote.conf"
fi

# Check if audispd-plugins installed
if ! dpkg -l | grep -q "^ii.*audispd-plugins"; then
    echo "FAIL: audispd-plugins not installed"
    exit 1
fi

# Check if au-remote.conf exists and active = yes
if [ ! -f "$AUDISP_REMOTE_CONF" ]; then
    echo "FAIL: $AUDISP_REMOTE_CONF not found"
    exit 1
fi

if ! grep -q "^active = yes" "$AUDISP_REMOTE_CONF"; then
    echo "FAIL: au-remote plugin not active"
    exit 1
fi

# Check if remote server configured with valid IP
if [ ! -f "$AUDISP_CONF" ]; then
    echo "FAIL: $AUDISP_CONF not found"
    exit 1
fi

if grep -qi "^remote_server" "$AUDISP_CONF"; then
    REMOTE_SERVER=$(grep -i "^remote_server" "$AUDISP_CONF" | sed 's/.*=\s*//' | tr -d ' ')
    
    # Validate IP address format (basic check for x.x.x.x pattern)
    if [[ "$REMOTE_SERVER" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Check for invalid IPs: localhost, 0.0.0.0, placeholder-looking addresses
        if [ "$REMOTE_SERVER" = "0.0.0.0" ] || [ "$REMOTE_SERVER" = "127.0.0.1" ]; then
            echo "FAIL: remote_server is set to invalid local address ($REMOTE_SERVER)"
            exit 1
        fi
        echo "PASS: audispd remote logging configured to $REMOTE_SERVER"
        exit 0
    else
        # Not a valid IP (could be hostname or placeholder like <remote_server_ip_address>)
        echo "FAIL: remote_server is not a valid IP address ($REMOTE_SERVER)"
        echo "NOTE: Set remote_server to actual remote syslog server IP in $AUDISP_CONF"
        exit 1
    fi
else
    echo "FAIL: remote_server not configured in $AUDISP_CONF"
    exit 1
fi
