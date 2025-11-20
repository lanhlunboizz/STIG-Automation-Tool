#!/bin/bash
# Remediation: Set account inactivity timeout to 35 days
# Rule: UBTU-24-010001

echo "Setting account inactivity timeout to 35 days..."

# Backup
cp /etc/default/useradd /etc/default/useradd.bak.$(date +%Y%m%d_%H%M%S)

# Set INACTIVE to 35
sed -i 's/^INACTIVE=.*/INACTIVE=35/' /etc/default/useradd

# If not exists, add it
if ! grep -q "^INACTIVE=" /etc/default/useradd; then
    echo "INACTIVE=35" >> /etc/default/useradd
fi

echo "Account inactivity timeout set to 35 days"
exit 0
