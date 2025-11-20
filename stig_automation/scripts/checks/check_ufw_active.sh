#!/bin/bash
# Check: UFW firewall active
# Rule: UBTU-24-100310

if ! command -v ufw &> /dev/null; then
    echo "FAIL: UFW is not installed"
    exit 1
fi

UFW_STATUS=$(ufw status | grep -i "Status:" | awk '{print $2}')

if [ "$UFW_STATUS" = "active" ]; then
    echo "PASS: UFW is active"
    exit 0
else
    echo "FAIL: UFW is not active (status: $UFW_STATUS)"
    exit 1
fi
