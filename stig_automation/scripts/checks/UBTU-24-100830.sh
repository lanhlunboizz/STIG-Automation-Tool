#!/bin/bash
# Check if SSH daemon is configured to use FIPS 140-3 approved MACs

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for MACs directive with HMAC-SHA2
if grep -qE "^MACs.*hmac-sha2-(512|256)" "$SSHD_CONFIG"; then
    echo "PASS: SSH daemon configured with FIPS 140-3 approved MACs"
    exit 0
else
    echo "FAIL: SSH daemon NOT configured with FIPS 140-3 approved MACs"
    exit 1
fi
