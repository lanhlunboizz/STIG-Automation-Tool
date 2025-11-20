#!/bin/bash
# Remediation: Disable SSH root login
# Rule: UBTU-24-010006

echo "Disabling SSH root login..."

SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup
cp $SSHD_CONFIG ${SSHD_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)

# Remove existing PermitRootLogin lines
sed -i '/^PermitRootLogin/d' $SSHD_CONFIG
sed -i '/^#PermitRootLogin/d' $SSHD_CONFIG

# Add PermitRootLogin no
echo "PermitRootLogin no" >> $SSHD_CONFIG

# Restart SSH service
systemctl restart sshd

echo "SSH root login disabled"
exit 0
