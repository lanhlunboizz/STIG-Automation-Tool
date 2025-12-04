#!/bin/bash
# Check if chrony package is installed

if dpkg -l | grep -q "^ii.*chrony "; then
    echo "PASS: chrony package is installed"
    exit 0
else
    echo "FAIL: chrony package is NOT installed"
    exit 1
fi
