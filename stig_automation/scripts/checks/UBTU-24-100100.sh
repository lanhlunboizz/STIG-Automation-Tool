#!/bin/bash
# Check: AIDE installed
# Rule: UBTU-24-100100

if command -v aide &> /dev/null; then
    echo "PASS: AIDE is installed"
    exit 0
else
    echo "FAIL: AIDE is not installed"
    exit 1
fi
