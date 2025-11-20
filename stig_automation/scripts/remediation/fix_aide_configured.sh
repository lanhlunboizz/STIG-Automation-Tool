#!/bin/bash
# Remediation: Initialize AIDE database
# Rule: UBTU-24-100110

echo "Initializing AIDE database..."

if ! command -v aide &> /dev/null; then
    echo "ERROR: AIDE is not installed. Install AIDE first."
    exit 1
fi

# Check if database already exists
if [ -f /var/lib/aide/aide.db ] || [ -f /var/lib/aide/aide.db.gz ]; then
    echo "AIDE database already exists"
    exit 0
fi

# Initialize AIDE database
echo "Running aideinit (this may take several minutes)..."
aideinit 2>&1

# Wait a moment for file to be created
sleep 3

# Move new database to production
if [ -f /var/lib/aide/aide.db.new ]; then
    mv -f /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    echo "AIDE database initialized successfully"
    exit 0
elif [ -f /var/lib/aide/aide.db.new.gz ]; then
    mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    echo "AIDE database initialized successfully (compressed)"
    exit 0
else
    echo "ERROR: Failed to create AIDE database"
    ls -la /var/lib/aide/ 2>&1
    exit 1
fi
