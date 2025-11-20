#!/bin/bash
# Check: auditd installed
# Rule: UBTU-24-100400

if command -v auditd &> /dev/null; then
    echo "PASS: auditd is installed"
    exit 0
else
    echo "FAIL: auditd is not installed"
    exit 1
fi
