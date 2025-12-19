#!/bin/bash
# Check if SSSD is configured to expire cached credentials after 1 day

SSSD_CONF="/etc/sssd/sssd.conf"

if [ ! -f "$SSSD_CONF" ]; then
    echo "FAIL: $SSSD_CONF not found"
    exit 1
fi

# Check for offline_credentials_expiration = 1
if grep -qE "^offline_credentials_expiration[[:space:]]*=[[:space:]]*1" "$SSSD_CONF"; then
    echo "PASS: Cached credentials expire after 1 day"
    exit 0
else
    echo "FAIL: offline_credentials_expiration not set to 1 day"
    exit 1
fi
