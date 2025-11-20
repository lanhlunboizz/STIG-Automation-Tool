#!/bin/bash
# Check: Automatic updates
# Rule: UBTU-24-010010

APT_CONFIG="/etc/apt/apt.conf.d/20auto-upgrades"

if [ ! -f "$APT_CONFIG" ]; then
    echo "FAIL: Automatic updates not configured"
    exit 1
fi

UPDATE_ENABLED=$(grep 'APT::Periodic::Update-Package-Lists' $APT_CONFIG | grep -o '"[0-9]*"' | tr -d '"')
UPGRADE_ENABLED=$(grep 'APT::Periodic::Unattended-Upgrade' $APT_CONFIG | grep -o '"[0-9]*"' | tr -d '"')

if [ "$UPDATE_ENABLED" = "1" ] && [ "$UPGRADE_ENABLED" = "1" ]; then
    echo "PASS: Automatic updates are enabled"
    exit 0
else
    echo "FAIL: Automatic updates not properly configured"
    exit 1
fi
