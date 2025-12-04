#!/bin/bash
# Remediation: Configure SSH daemon to use FIPS 140-3 approved MACs

echo "Starting remediation: Configuring SSH FIPS-approved MACs..."

SSHD_CONFIG="/etc/ssh/sshd_config"
FIPS_MACS="hmac-sha2-512,hmac-sha2-256"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "ERROR: $SSHD_CONFIG not found"
    exit 1
fi

# Backup config
BACKUP_FILE="${SSHD_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$SSHD_CONFIG" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Check if MACs directive already exists
if grep -qE "^MACs " "$SSHD_CONFIG"; then
    echo "Updating existing MACs directive..."
    sed -i "s/^MACs .*/MACs $FIPS_MACS/" "$SSHD_CONFIG"
else
    echo "Adding MACs directive..."
    echo "" >> "$SSHD_CONFIG"
    echo "# STIG UBTU-24-100830: FIPS 140-3 approved MACs" >> "$SSHD_CONFIG"
    echo "MACs $FIPS_MACS" >> "$SSHD_CONFIG"
fi

# Verify configuration
if grep -qE "^MACs.*hmac-sha2-(512|256)" "$SSHD_CONFIG"; then
    echo "Configuration updated successfully"
    
    # Restart SSH daemon
    echo "Restarting SSH daemon..."
    if systemctl restart sshd 2>&1 || systemctl restart ssh 2>&1; then
        echo "SUCCESS: SSH daemon restarted with FIPS-approved MACs"
        exit 0
    else
        echo "WARNING: Configuration updated but SSH daemon restart failed"
        exit 1
    fi
else
    echo "ERROR: Failed to configure FIPS-approved MACs"
    exit 1
fi
