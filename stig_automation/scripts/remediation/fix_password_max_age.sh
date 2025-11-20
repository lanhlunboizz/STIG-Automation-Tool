#!/bin/bash
# Remediation: Set maximum password age
# Rule: UBTU-24-010004

echo "Setting maximum password age to 60 days..."

LOGIN_DEFS="/etc/login.defs"

# Backup
cp $LOGIN_DEFS ${LOGIN_DEFS}.bak.$(date +%Y%m%d_%H%M%S)

# Set PASS_MAX_DAYS
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS\t60/' $LOGIN_DEFS

echo "Maximum password age set to 60 days"
exit 0
