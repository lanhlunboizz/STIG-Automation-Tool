#!/bin/bash
# Check: rsyslog installed and running
# Rule: UBTU-24-100200

# Check if rsyslog package is installed
if ! dpkg -l | grep -q "^ii.*rsyslog "; then
    echo "FAIL: rsyslog package is not installed"
    exit 1
fi

# Check if rsyslog service is enabled
if ! systemctl is-enabled rsyslog.service &>/dev/null; then
    echo "FAIL: rsyslog service is not enabled"
    exit 1
fi

# Check if rsyslog service is active/running
if systemctl is-active rsyslog.service &>/dev/null; then
    echo "PASS: rsyslog is installed, enabled, and running"
    exit 0
else
    echo "FAIL: rsyslog is not running"
    exit 1
fi
