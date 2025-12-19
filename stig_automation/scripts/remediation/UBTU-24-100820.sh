#!/bin/bash
# Remediation: Configure SSH daemon to use FIPS 140-3 approved ciphers

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root or with sudo"
    exit 1
fi

echo "Starting remediation: Configuring SSH FIPS-approved ciphers..."

# Check if openssh-server is installed
if ! dpkg -l | grep -q "^ii.*openssh-server"; then
    echo "ERROR: openssh-server not installed. Install it first (UBTU-24-100800)"
    exit 1
fi

# Wait for SSH service to be ready
sleep 2

SSHD_CONFIG="/etc/ssh/sshd_config"
# STIG UBTU-24-100820 requires exactly these 4 ciphers in this order
FIPS_CIPHERS="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "ERROR: $SSHD_CONFIG not found"
    exit 1
fi

# Backup config
BACKUP_FILE="${SSHD_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$SSHD_CONFIG" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Check if Ciphers directive already exists
if grep -qE "^Ciphers " "$SSHD_CONFIG"; then
    echo "Updating existing Ciphers directive..."
    sed -i "s/^Ciphers .*/Ciphers $FIPS_CIPHERS/" "$SSHD_CONFIG"
else
    echo "Adding Ciphers directive..."
    echo "" >> "$SSHD_CONFIG"
    echo "# STIG UBTU-24-100820: FIPS 140-3 approved ciphers" >> "$SSHD_CONFIG"
    echo "Ciphers $FIPS_CIPHERS" >> "$SSHD_CONFIG"
fi

# Verify configuration
if grep -qE "^Ciphers.*aes(256|128)-(ctr|gcm@openssh.com)" "$SSHD_CONFIG"; then
    echo "Configuration updated successfully"
    
    # Restart SSH daemon
    echo "Restarting SSH daemon..."
    if systemctl restart sshd 2>&1 || systemctl restart ssh 2>&1; then
        echo "SUCCESS: SSH daemon restarted with FIPS-approved ciphers"
        exit 0
    else
        echo "WARNING: Configuration updated but SSH daemon restart failed"
        exit 1
    fi
else
    echo "ERROR: Failed to configure FIPS-approved ciphers"
    exit 1
fi
