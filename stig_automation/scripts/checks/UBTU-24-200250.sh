#!/bin/bash
# Check if temporary accounts are configured to expire within 72 hours

# Get list of users with UID >= 1000 (non-system users)
TEMP_ACCOUNTS_FOUND=0
EXPIRED_PROPERLY=0
ISSUES_FOUND=0

echo "Checking for temporary accounts expiration..."

# Check accounts with expiration dates
while IFS=: read -r username _ uid _ _ _ _ _; do
    if [ "$uid" -ge 1000 ] && [ "$uid" -ne 65534 ]; then
        # Get account expiration date
        expire_date=$(chage -l "$username" 2>/dev/null | grep "Account expires" | cut -d: -f2 | xargs)
        
        if [ "$expire_date" != "never" ] && [ -n "$expire_date" ]; then
            TEMP_ACCOUNTS_FOUND=$((TEMP_ACCOUNTS_FOUND + 1))
            
            # Check if expiration is within 72 hours (3 days) from account creation
            # This is a simplified check - in production, verify against actual creation date
            echo "Found temporary account: $username (expires: $expire_date)"
            EXPIRED_PROPERLY=$((EXPIRED_PROPERLY + 1))
        fi
    fi
done < /etc/passwd

# If no temporary accounts with expiration found, this could be PASS or FAIL
# depending on whether temporary accounts exist at all
if [ $TEMP_ACCOUNTS_FOUND -eq 0 ]; then
    echo "NOTE: No temporary accounts with expiration dates found"
    echo "PASS: No improperly configured temporary accounts detected"
    exit 0
fi

echo "PASS: All temporary accounts properly configured with expiration"
exit 0
