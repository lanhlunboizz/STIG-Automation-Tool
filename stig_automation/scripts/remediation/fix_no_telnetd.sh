#!/bin/bash
# Remediation: Remove telnetd package
# Rule: UBTU-24-100030

echo "Removing telnetd package..."

if dpkg -l | grep -q "^ii.*telnetd"; then
    apt-get purge -y telnetd
    echo "telnetd package removed"
else
    echo "telnetd package is not installed"
fi

exit 0
