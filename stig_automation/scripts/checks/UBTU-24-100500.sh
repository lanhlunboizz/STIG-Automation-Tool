#!/bin/bash
# Check if apparmor package is installed

if dpkg -l | grep -q "^ii.*apparmor "; then
    echo "PASS: apparmor package is installed"
    exit 0
else
    echo "FAIL: apparmor package is NOT installed"
    exit 1
fi
