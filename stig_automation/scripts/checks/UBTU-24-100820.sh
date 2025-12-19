#!/bin/bash
# Check if SSH daemon is configured to use FIPS 140-3 approved ciphers

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for Ciphers directive with exact FIPS-approved ciphers
# STIG requires: aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr
CIPHERS_LINE=$(grep -E "^Ciphers " "$SSHD_CONFIG" 2>/dev/null)

if echo "$CIPHERS_LINE" | grep -q "aes256-gcm@openssh.com" && \
   echo "$CIPHERS_LINE" | grep -q "aes128-gcm@openssh.com" && \
   echo "$CIPHERS_LINE" | grep -q "aes256-ctr" && \
   echo "$CIPHERS_LINE" | grep -q "aes128-ctr"; then
    echo "PASS: SSH daemon configured with FIPS 140-3 approved ciphers"
    exit 0
else
    echo "FAIL: SSH daemon NOT configured with FIPS 140-3 approved ciphers"
    echo "Required: aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
    exit 1
fi
