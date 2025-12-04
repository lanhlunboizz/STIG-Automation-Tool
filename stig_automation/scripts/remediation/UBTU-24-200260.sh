#!/bin/bash
# Remediation: Configure automatic account locking after 30 days of inactivity

echo "Starting remediation: Configuring automatic account locking..."

USERADD_DEFAULTS="/etc/default/useradd"

if [ ! -f "$USERADD_DEFAULTS" ]; then
    echo "ERROR: $USERADD_DEFAULTS not found"
    exit 1
fi

# Backup config
BACKUP_FILE="${USERADD_DEFAULTS}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$USERADD_DEFAULTS" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Check if INACTIVE is already set
if grep -qE "^INACTIVE=" "$USERADD_DEFAULTS"; then
    echo "Updating existing INACTIVE setting..."
    sed -i 's/^INACTIVE=.*/INACTIVE=30/' "$USERADD_DEFAULTS"
else
    echo "Adding INACTIVE=30 setting..."
    echo "" >> "$USERADD_DEFAULTS"
    echo "# STIG UBTU-24-200260: Lock accounts after 30 days of inactivity" >> "$USERADD_DEFAULTS"
    echo "INACTIVE=30" >> "$USERADD_DEFAULTS"
fi

# Verify configuration
if grep -qE "^INACTIVE=30" "$USERADD_DEFAULTS"; then
    echo "Configuration updated successfully in $USERADD_DEFAULTS"
    
    # Apply to existing user accounts (non-system users)
    echo ""
    echo "Applying INACTIVE=30 to existing user accounts..."
    for user in $(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
        echo "Setting inactive period for user: $user"
        chage -I 30 "$user" 2>&1
    done
    
    echo ""
    echo "SUCCESS: Automatic account locking after 30 days configured"
    echo "NOTE: This applies to password expiration - accounts lock 30 days after password expires"
    exit 0
else
    echo "ERROR: Failed to configure INACTIVE setting"
    exit 1
fi
