#!/bin/bash
# Remediation: Configure SSH FIPS 140-2 ciphers
# Rule: UBTU-24-010005

echo "Configuring SSH with FIPS 140-2 approved ciphers..."

SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup
cp $SSHD_CONFIG ${SSHD_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)

# Remove existing Ciphers line
sed -i '/^Ciphers/d' $SSHD_CONFIG

# Add approved ciphers
echo "Ciphers aes256-ctr,aes192-ctr,aes128-ctr" >> $SSHD_CONFIG

# Restart SSH service
systemctl restart sshd

echo "SSH ciphers configured with FIPS 140-2 approved algorithms"
exit 0
