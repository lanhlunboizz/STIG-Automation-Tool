#!/bin/bash
# Check: SSH FIPS 140-2 ciphers
# Rule: UBTU-24-010005

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for approved ciphers
CIPHERS=$(grep "^Ciphers" $SSHD_CONFIG)

if [ -z "$CIPHERS" ]; then
    echo "FAIL: Ciphers not configured in sshd_config"
    exit 1
fi

# Approved ciphers
if echo "$CIPHERS" | grep -q "aes256-ctr,aes192-ctr,aes128-ctr"; then
    echo "PASS: SSH using approved ciphers"
    exit 0
else
    echo "FAIL: SSH not using approved FIPS 140-2 ciphers"
    exit 1
fi
