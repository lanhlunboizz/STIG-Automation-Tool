#!/bin/bash
# Check if sssd, libpam-sss, and libnss-sss packages are installed

missing_packages=()

if ! dpkg -l | grep -q "^ii.*sssd "; then
    missing_packages+=("sssd")
fi

if ! dpkg -l | grep -q "^ii.*libpam-sss"; then
    missing_packages+=("libpam-sss")
fi

if ! dpkg -l | grep -q "^ii.*libnss-sss"; then
    missing_packages+=("libnss-sss")
fi

if [ ${#missing_packages[@]} -eq 0 ]; then
    echo "PASS: All required SSSD packages are installed"
    exit 0
else
    echo "FAIL: Missing packages: ${missing_packages[*]}"
    exit 1
fi
