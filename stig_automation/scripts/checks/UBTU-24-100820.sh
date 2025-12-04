#!/bin/bash
# Check if SSH daemon is configured to use FIPS 140-3 approved ciphers

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for Ciphers directive with FIPS-approved ciphers
# FIPS 140-3 approved ciphers: aes256-ctr, aes192-ctr, aes128-ctr, aes256-gcm@openssh.com, aes128-gcm@openssh.com
if grep -qE "^Ciphers.*aes(256|192|128)-(ctr|gcm@openssh.com)" "$SSHD_CONFIG"; then
    echo "PASS: SSH daemon configured with FIPS 140-3 approved ciphers"
    exit 0
else
    echo "FAIL: SSH daemon NOT configured with FIPS 140-3 approved ciphers"
    exit 1
fi
