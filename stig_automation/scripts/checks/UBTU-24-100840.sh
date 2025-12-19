#!/bin/bash
# Check if SSH daemon is configured to use FIPS-validated key exchange algorithms

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

# Check for KexAlgorithms directive with FIPS-validated algorithms
# STIG requires exactly these 6 algorithms
KEX_LINE=$(grep -E "^KexAlgorithms " "$SSHD_CONFIG" 2>/dev/null)

if echo "$KEX_LINE" | grep -q "ecdh-sha2-nistp521" && \
   echo "$KEX_LINE" | grep -q "ecdh-sha2-nistp384" && \
   echo "$KEX_LINE" | grep -q "ecdh-sha2-nistp256" && \
   echo "$KEX_LINE" | grep -q "diffie-hellman-group-exchange-sha256" && \
   echo "$KEX_LINE" | grep -q "diffie-hellman-group16-sha512" && \
   echo "$KEX_LINE" | grep -q "diffie-hellman-group14-sha256"; then
    echo "PASS: SSH daemon configured with FIPS-validated key exchange algorithms"
    exit 0
else
    echo "FAIL: SSH daemon NOT configured with FIPS-validated key exchange algorithms"
    echo "Required: ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group14-sha256"
    exit 1
fi
