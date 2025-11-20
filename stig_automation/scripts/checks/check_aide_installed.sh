#!/bin/bash
# Check: AIDE installed
# Rule: UBTU-24-010007

if command -v aide &> /dev/null; then
    # Check if AIDE database exists
    if [ -f /var/lib/aide/aide.db ] || [ -f /var/lib/aide/aide.db.gz ]; then
        echo "PASS: AIDE is installed and initialized"
        exit 0
    else
        echo "FAIL: AIDE installed but not initialized"
        exit 1
    fi
else
    echo "FAIL: AIDE is not installed"
    exit 1
fi
