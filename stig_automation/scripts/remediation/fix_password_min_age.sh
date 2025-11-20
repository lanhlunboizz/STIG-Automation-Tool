#!/bin/bash
# Remediation: Set minimum password age
# Rule: UBTU-24-010003

echo "Setting minimum password age to 1 day..."

LOGIN_DEFS="/etc/login.defs"

# Backup
cp $LOGIN_DEFS ${LOGIN_DEFS}.bak.$(date +%Y%m%d_%H%M%S)

# Set PASS_MIN_DAYS
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS\t1/' $LOGIN_DEFS

echo "Minimum password age set to 1 day"
exit 0
