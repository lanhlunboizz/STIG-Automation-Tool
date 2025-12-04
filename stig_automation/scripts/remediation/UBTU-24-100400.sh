#!/bin/bash
# Remediation: Install auditd
# Rule: UBTU-24-100400

echo "Installing auditd..."

apt-get update
apt-get install -y auditd audispd-plugins

if command -v auditd &> /dev/null; then
    echo "auditd installed successfully"
    exit 0
else
    echo "ERROR: Failed to install auditd"
    exit 1
fi
