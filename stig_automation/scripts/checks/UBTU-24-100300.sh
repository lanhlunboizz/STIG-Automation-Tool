#!/bin/bash
# Check: UFW firewall installed
# Rule: UBTU-24-100300

if command -v ufw &> /dev/null; then
    echo "PASS: UFW is installed"
    exit 0
else
    echo "FAIL: UFW is not installed"
    exit 1
fi
