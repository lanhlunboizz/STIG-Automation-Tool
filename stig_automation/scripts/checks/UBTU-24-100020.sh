#!/bin/bash
# Check: ntp package must not be installed
# Rule: UBTU-24-100020

if dpkg -l | grep -q "^ii.*ntp"; then
    echo "FAIL: ntp package is installed"
    exit 1
else
    echo "PASS: ntp package is not installed"
    exit 0
fi
