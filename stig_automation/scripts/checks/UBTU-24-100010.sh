#!/bin/bash
# Check: systemd-timesyncd must not be installed
# Rule: UBTU-24-100010

if dpkg -l | grep -q "^ii.*systemd-timesyncd"; then
    echo "FAIL: systemd-timesyncd is installed"
    exit 1
else
    echo "PASS: systemd-timesyncd is not installed"
    exit 0
fi
