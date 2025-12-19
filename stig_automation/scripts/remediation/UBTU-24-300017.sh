#!/bin/bash
# Remediation: Configure pam_faildelay with 4 second delay

echo "Starting remediation: Configuring login delay after failed attempts..."

PAM_AUTH="/etc/pam.d/common-auth"

if [ ! -f "$PAM_AUTH" ]; then
    echo "ERROR: $PAM_AUTH not found"
    exit 1
fi

# Backup file
BACKUP_FILE="${PAM_AUTH}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$PAM_AUTH" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Check if already configured
if grep -qE "^auth[[:space:]]+required[[:space:]]+pam_faildelay.so[[:space:]]+delay=4000000" "$PAM_AUTH"; then
    echo "Login delay already configured"
    exit 0
fi

# Remove existing pam_faildelay lines to avoid duplicates
sed -i '/pam_faildelay.so/d' "$PAM_AUTH"

# Add pam_faildelay configuration at the beginning
echo "Adding pam_faildelay configuration..."
sed -i '1i# STIG UBTU-24-300017: Enforce 4 second delay after failed login\nauth required pam_faildelay.so delay=4000000' "$PAM_AUTH"

# Verify configuration
if grep -qE "^auth[[:space:]]+required[[:space:]]+pam_faildelay.so[[:space:]]+delay=4000000" "$PAM_AUTH"; then
    echo "SUCCESS: Login delay of 4 seconds configured after failed attempts"
    echo "NOTE: Delay = 4000000 microseconds = 4 seconds"
    exit 0
else
    echo "ERROR: Failed to configure pam_faildelay"
    exit 1
fi
