#!/bin/bash
# Remediation: Restrict core dumps
# Rule: UBTU-24-010011

echo "Restricting core dumps..."

LIMITS_CONF="/etc/security/limits.conf"
SYSCTL_CONF="/etc/sysctl.conf"

# Backup
cp $LIMITS_CONF ${LIMITS_CONF}.bak.$(date +%Y%m%d_%H%M%S)
cp $SYSCTL_CONF ${SYSCTL_CONF}.bak.$(date +%Y%m%d_%H%M%S)

# Configure limits.conf
if ! grep -q "^\*.*hard.*core.*0" $LIMITS_CONF; then
    echo "* hard core 0" >> $LIMITS_CONF
fi

# Configure sysctl
if ! grep -q "^fs.suid_dumpable" $SYSCTL_CONF; then
    echo "fs.suid_dumpable = 0" >> $SYSCTL_CONF
else
    sed -i 's/^fs.suid_dumpable.*/fs.suid_dumpable = 0/' $SYSCTL_CONF
fi

# Apply sysctl changes
sysctl -p

echo "Core dumps restricted"
exit 0
