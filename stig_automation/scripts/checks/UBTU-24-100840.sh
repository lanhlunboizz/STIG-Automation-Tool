#!/bin/bash
# Check if SSH daemon is configured to use FIPS-validated key exchange algorithms

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for KexAlgorithms directive with FIPS-validated algorithms
# FIPS-validated: ecdh-sha2-nistp256, ecdh-sha2-nistp384, ecdh-sha2-nistp521, diffie-hellman-group-exchange-sha256
if grep -qE "^KexAlgorithms.*ecdh-sha2-nistp(256|384|521)" "$SSHD_CONFIG"; then
    echo "PASS: SSH daemon configured with FIPS-validated key exchange algorithms"
    exit 0
else
    echo "FAIL: SSH daemon NOT configured with FIPS-validated key exchange algorithms"
    exit 1
fi
