#!/bin/bash
# Check if opensc-pkcs11 package is installed (for PIV/CAC support)

if dpkg -l | grep -q "^ii.*opensc-pkcs11"; then
    echo "PASS: opensc-pkcs11 package is installed"
    exit 0
else
    echo "FAIL: opensc-pkcs11 package is NOT installed"
    exit 1
fi
