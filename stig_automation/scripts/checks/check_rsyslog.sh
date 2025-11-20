#!/bin/bash
# Check: rsyslog installed and running
# Rule: UBTU-24-100200

if ! command -v rsyslogd &> /dev/null; then
    echo "FAIL: rsyslog is not installed"
    exit 1
fi

if systemctl is-active --quiet rsyslog; then
    echo "PASS: rsyslog is installed and running"
    exit 0
else
    echo "FAIL: rsyslog is not running"
    exit 1
fi
