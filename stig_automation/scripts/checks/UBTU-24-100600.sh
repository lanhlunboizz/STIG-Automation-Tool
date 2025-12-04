#!/bin/bash
# Check if libpam-pwquality package is installed

if dpkg -l | grep -q "^ii.*libpam-pwquality"; then
    echo "PASS: libpam-pwquality package is installed"
    exit 0
else
    echo "FAIL: libpam-pwquality package is NOT installed"
    exit 1
fi
