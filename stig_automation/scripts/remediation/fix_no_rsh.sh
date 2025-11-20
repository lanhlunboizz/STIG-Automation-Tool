#!/bin/bash
# Remediation: Remove rsh-server package
# Rule: UBTU-24-100040

echo "Removing rsh-server package..."

if dpkg -l | grep -q "^ii.*rsh-server"; then
    apt-get purge -y rsh-server
    echo "rsh-server package removed"
else
    echo "rsh-server package is not installed"
fi

exit 0
