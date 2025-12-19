#!/bin/bash
# Check if SSH daemon is configured to use FIPS 140-3 approved MACs

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for MACs directive with FIPS-approved MACs
# STIG requires: hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
MACS_LINE=$(grep -E "^MACs " "$SSHD_CONFIG" 2>/dev/null)

if echo "$MACS_LINE" | grep -q "hmac-sha2-512-etm@openssh.com" && \
   echo "$MACS_LINE" | grep -q "hmac-sha2-256-etm@openssh.com" && \
   echo "$MACS_LINE" | grep -q "hmac-sha2-512" && \
   echo "$MACS_LINE" | grep -q "hmac-sha2-256"; then
    echo "PASS: SSH daemon configured with FIPS 140-3 approved MACs"
    exit 0
else
    echo "FAIL: SSH daemon NOT configured with FIPS 140-3 approved MACs"
    echo "Required: hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
    exit 1
fi
