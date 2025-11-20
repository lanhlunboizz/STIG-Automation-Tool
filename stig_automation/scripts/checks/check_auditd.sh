#!/bin/bash
# Check: Auditd service
# Rule: UBTU-24-010008

# Check if auditd is installed
if ! command -v auditd &> /dev/null; then
    echo "FAIL: auditd is not installed"
    exit 1
fi

# Check if auditd is running
if systemctl is-active --quiet auditd; then
    echo "PASS: auditd is installed and running"
    exit 0
else
    echo "FAIL: auditd is installed but not running"
    exit 1
fi
