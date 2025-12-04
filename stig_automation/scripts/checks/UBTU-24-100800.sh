#!/bin/bash
# Check if OpenSSH server package is installed

if dpkg -l | grep -q "^ii.*openssh-server"; then
    echo "PASS: openssh-server package is installed"
    exit 0
else
    echo "FAIL: openssh-server package is NOT installed"
    exit 1
fi
