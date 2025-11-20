#!/bin/bash
# Remediation: Configure password complexity
# Rule: UBTU-24-010002

echo "Configuring password complexity requirements..."

CONFIG_FILE="/etc/security/pwquality.conf"

# Backup
cp $CONFIG_FILE ${CONFIG_FILE}.bak.$(date +%Y%m%d_%H%M%S)

# Configure password quality
cat >> $CONFIG_FILE <<EOF

# STIG Password Complexity Requirements
minlen = 14
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
difok = 8
maxrepeat = 3
EOF

echo "Password complexity configured"
exit 0
