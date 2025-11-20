#!/bin/bash
# Check: rsh-server must not be installed
# Rule: UBTU-24-100040

if dpkg -l | grep -q "^ii.*rsh-server"; then
    echo "FAIL: rsh-server package is installed"
    exit 1
else
    echo "PASS: rsh-server package is not installed"
    exit 0
fi
