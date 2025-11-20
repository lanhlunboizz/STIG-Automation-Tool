#!/bin/bash
# Check: AIDE database initialized
# Rule: UBTU-24-100110

if [ -f /var/lib/aide/aide.db ] || [ -f /var/lib/aide/aide.db.gz ]; then
    echo "PASS: AIDE database is initialized"
    exit 0
else
    echo "FAIL: AIDE database not initialized (run aideinit)"
    exit 1
fi
