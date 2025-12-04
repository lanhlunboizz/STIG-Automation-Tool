#!/bin/bash
# Remediation: Configure automatic expiration for temporary accounts within 72 hours

echo "Starting remediation: Configuring temporary account expiration policy..."

echo ""
echo "=========================================="
echo "IMPORTANT: Manual Account Management Required"
echo "=========================================="
echo ""
echo "This remediation requires manual intervention for each temporary account:"
echo ""
echo "For NEW temporary accounts, use:"
echo "  sudo useradd -e \$(date -d '+3 days' +%Y-%m-%d) username"
echo ""
echo "For EXISTING temporary accounts, use:"
echo "  sudo chage -E \$(date -d '+3 days' +%Y-%m-%d) username"
echo ""
echo "To list all user accounts and their expiration:"
echo "  for user in \$(awk -F: '\$3 >= 1000 && \$3 != 65534 {print \$1}' /etc/passwd); do"
echo "    echo -n \"\$user: \""
echo "    chage -l \"\$user\" | grep 'Account expires'"
echo "  done"
echo ""
echo "To verify temporary account expiration dates:"
echo "  chage -l username"
echo ""

# List current users with expiration info
echo "Current user accounts (UID >= 1000):"
echo "----------------------------------------"
for user in $(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
    expire_info=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2 | xargs)
    echo "$user: expires $expire_info"
done
echo ""

echo "MANUAL ACTION REQUIRED: Set expiration dates for temporary accounts"
echo "This is a policy control that requires administrator judgment"

# This is a manual remediation - requires admin intervention
exit 1
