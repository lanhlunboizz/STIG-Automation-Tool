#!/bin/bash
# Remediation: Initialize AIDE database
# Rule: UBTU-24-100110

echo "Initializing AIDE database..."

if ! command -v aide &> /dev/null; then
    echo "ERROR: AIDE is not installed. Install AIDE first."
    exit 1
fi

# Initialize AIDE database
aideinit

# Move new database to production
if [ -f /var/lib/aide/aide.db.new ]; then
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    echo "AIDE database initialized successfully"
    exit 0
else
    echo "ERROR: Failed to create AIDE database"
    exit 1
fi
