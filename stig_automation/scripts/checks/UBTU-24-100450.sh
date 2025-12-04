#!/bin/bash
# Check: audispd remote logging configured
# Rule: UBTU-24-100450

AUDISP_REMOTE_CONF="/etc/audisp/plugins.d/au-remote.conf"
AUDISP_CONF="/etc/audisp/audisp-remote.conf"

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

# Check if remote server configured
if [ ! -f "$AUDISP_CONF" ]; then
    echo "FAIL: $AUDISP_CONF not found"
    exit 1
fi

if grep -q "^remote_server = " "$AUDISP_CONF"; then
    REMOTE_SERVER=$(grep "^remote_server = " "$AUDISP_CONF" | awk '{print $3}')
    if [ -n "$REMOTE_SERVER" ] && [ "$REMOTE_SERVER" != "0.0.0.0" ]; then
        echo "PASS: audispd remote logging configured to $REMOTE_SERVER"
        exit 0
    else
        echo "FAIL: remote_server not properly configured"
        exit 1
    fi
else
    echo "FAIL: remote_server not configured in $AUDISP_CONF"
    exit 1
fi
