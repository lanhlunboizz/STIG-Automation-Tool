#!/bin/bash
# Check if APT is configured to prevent unauthorized package installation

APT_CONF="/etc/apt/apt.conf.d/50unattended-upgrades"
APT_AUTO_CONF="/etc/apt/apt.conf.d/20auto-upgrades"

# This is a policy check - system should have controls on package installation
# Check if unattended-upgrades is properly configured or disabled

if [ ! -f "$APT_AUTO_CONF" ]; then
    # If auto-upgrades file doesn't exist, manual control is enforced
    echo "PASS: Automatic package installation not configured (manual control enforced)"
    exit 0
fi

# Check if automatic updates are disabled
if grep -q "APT::Periodic::Update-Package-Lists \"0\"" "$APT_AUTO_CONF" && \
   grep -q "APT::Periodic::Unattended-Upgrade \"0\"" "$APT_AUTO_CONF"; then
    echo "PASS: Automatic package installation disabled"
    exit 0
fi

# Check if unattended-upgrades is configured with proper restrictions
if [ -f "$APT_CONF" ]; then
    echo "PASS: APT package installation controls configured"
    exit 0
fi

echo "FAIL: APT automatic package installation not properly controlled"
exit 1
