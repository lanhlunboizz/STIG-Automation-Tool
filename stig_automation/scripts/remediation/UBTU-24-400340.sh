#!/bin/bash
# Remediation: Configure SSSD to expire cached credentials after 1 day

echo "Starting remediation: Configuring cached credentials expiration..."

SSSD_CONF="/etc/sssd/sssd.conf"
SSSD_DIR="/etc/sssd"

# Check if SSSD is installed
if ! dpkg -l | grep -q "^ii.*sssd "; then
    echo "ERROR: SSSD is not installed. Install SSSD first (UBTU-24-100650)"
    exit 1
fi

# Create SSSD directory if not exists
if [ ! -d "$SSSD_DIR" ]; then
    mkdir -p "$SSSD_DIR"
    chmod 700 "$SSSD_DIR"
fi

# Check if sssd.conf exists
if [ ! -f "$SSSD_CONF" ]; then
    echo "Creating default $SSSD_CONF..."
    cat > "$SSSD_CONF" << 'EOF'
[sssd]
services = nss, pam
domains = LDAP

[nss]

[pam]
offline_credentials_expiration = 1
EOF
    chmod 600 "$SSSD_CONF"
else
    # Backup existing file
    BACKUP_FILE="${SSSD_CONF}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$SSSD_CONF" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
    
    # Check if already configured
    if grep -qE "^offline_credentials_expiration[[:space:]]*=[[:space:]]*1" "$SSSD_CONF"; then
        echo "Cached credentials expiration already configured"
        exit 0
    fi
    
    # Remove existing offline_credentials_expiration lines
    sed -i '/offline_credentials_expiration/d' "$SSSD_CONF"
    
    # Add configuration to [pam] section
    if grep -q "^\[pam\]" "$SSSD_CONF"; then
        echo "Adding offline_credentials_expiration to existing [pam] section..."
        sed -i '/^\[pam\]/a offline_credentials_expiration = 1' "$SSSD_CONF"
    else
        echo "Creating [pam] section with offline_credentials_expiration..."
        echo "" >> "$SSSD_CONF"
        echo "# STIG UBTU-24-400340: Cached credentials expiration" >> "$SSSD_CONF"
        echo "[pam]" >> "$SSSD_CONF"
        echo "offline_credentials_expiration = 1" >> "$SSSD_CONF"
    fi
fi

# Set proper permissions
chmod 600 "$SSSD_CONF"

# Restart SSSD service
echo "Restarting SSSD service..."
if systemctl restart sssd 2>&1; then
    echo "SSSD service restarted successfully"
else
    echo "WARNING: Failed to restart SSSD service"
fi

# Verify configuration
if grep -qE "^offline_credentials_expiration[[:space:]]*=[[:space:]]*1" "$SSSD_CONF"; then
    echo "SUCCESS: Cached credentials expiration configured (1 day)"
    exit 0
else
    echo "ERROR: Failed to configure cached credentials expiration"
    exit 1
fi
