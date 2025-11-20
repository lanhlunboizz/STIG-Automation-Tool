#!/bin/bash
# Remediation: Remove ntp package
# Rule: UBTU-24-100020

echo "Removing ntp package..."

if dpkg -l | grep -q "^ii.*ntp"; then
    apt-get purge -y ntp
    echo "ntp package removed"
else
    echo "ntp package is not installed"
fi

exit 0
