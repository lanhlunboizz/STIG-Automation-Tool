#!/bin/bash
# Remediation: Configure SSH daemon to use FIPS-validated key exchange algorithms

echo "Starting remediation: Configuring SSH FIPS-validated key exchange algorithms..."

SSHD_CONFIG="/etc/ssh/sshd_config"
FIPS_KEX="ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group14-sha256"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "ERROR: $SSHD_CONFIG not found"
    exit 1
fi

# Backup config
BACKUP_FILE="${SSHD_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$SSHD_CONFIG" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Check if KexAlgorithms directive already exists
if grep -qE "^KexAlgorithms " "$SSHD_CONFIG"; then
    echo "Updating existing KexAlgorithms directive..."
    sed -i "s/^KexAlgorithms .*/KexAlgorithms $FIPS_KEX/" "$SSHD_CONFIG"
else
    echo "Adding KexAlgorithms directive..."
    echo "" >> "$SSHD_CONFIG"
    echo "# STIG UBTU-24-100840: FIPS-validated key exchange algorithms" >> "$SSHD_CONFIG"
    echo "KexAlgorithms $FIPS_KEX" >> "$SSHD_CONFIG"
fi

# Verify configuration
if grep -qE "^KexAlgorithms.*ecdh-sha2-nistp(256|384|521)" "$SSHD_CONFIG"; then
    echo "Configuration updated successfully"
    
    # Restart SSH daemon
    echo "Restarting SSH daemon..."
    if systemctl restart sshd 2>&1 || systemctl restart ssh 2>&1; then
        echo "SUCCESS: SSH daemon restarted with FIPS-validated key exchange algorithms"
        exit 0
    else
        echo "WARNING: Configuration updated but SSH daemon restart failed"
        exit 1
    fi
else
    echo "ERROR: Failed to configure FIPS-validated key exchange algorithms"
    exit 1
fi
