#!/bin/bash
# Check: telnetd must not be installed
# Rule: UBTU-24-100030

if dpkg -l | grep -q "^ii.*telnetd"; then
    echo "FAIL: telnetd package is installed"
    exit 1
else
    echo "PASS: telnetd package is not installed"
    exit 0
fi
