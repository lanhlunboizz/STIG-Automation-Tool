#!/bin/bash
# Remediation: Configure pam_faillock with deny=3 and unlock_time=0

echo "Starting remediation: Configuring account lockout after failed login attempts..."

PAM_AUTH="/etc/pam.d/common-auth"
PAM_ACCOUNT="/etc/pam.d/common-account"

if [ ! -f "$PAM_AUTH" ]; then
    echo "ERROR: $PAM_AUTH not found"
    exit 1
fi

# Backup files
BACKUP_AUTH="${PAM_AUTH}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$PAM_AUTH" "$BACKUP_AUTH"
echo "Backup created: $BACKUP_AUTH"

if [ -f "$PAM_ACCOUNT" ]; then
    BACKUP_ACCOUNT="${PAM_ACCOUNT}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$PAM_ACCOUNT" "$BACKUP_ACCOUNT"
    echo "Backup created: $BACKUP_ACCOUNT"
fi

# Install libpam-pwquality if not present (includes pam_faillock)
if ! dpkg -l | grep -q "libpam-pwquality"; then
    echo "Installing libpam-pwquality..."
    apt-get update -qq
    apt-get install -y libpam-pwquality
fi

# Remove existing pam_faillock lines to avoid duplicates
sed -i '/pam_faillock.so/d' "$PAM_AUTH"
if [ -f "$PAM_ACCOUNT" ]; then
    sed -i '/pam_faillock.so/d' "$PAM_ACCOUNT"
fi

# Add pam_faillock configuration to common-auth
echo "Configuring pam_faillock in $PAM_AUTH..."

# Insert after pam_unix.so line
sed -i '/pam_unix.so/a # STIG UBTU-24-200610: Lock account after 3 failed attempts\nauth required pam_faillock.so preauth silent deny=3 unlock_time=0\nauth [default=die] pam_faillock.so authfail deny=3 unlock_time=0' "$PAM_AUTH"

# Add account requirement
if [ -f "$PAM_ACCOUNT" ]; then
    echo "Configuring pam_faillock in $PAM_ACCOUNT..."
    sed -i '1i# STIG UBTU-24-200610: Account lockout\naccount required pam_faillock.so' "$PAM_ACCOUNT"
fi

# Verify configuration
if grep -q "pam_faillock.so" "$PAM_AUTH" && \
   grep "pam_faillock.so" "$PAM_AUTH" | grep -q "deny=3" && \
   grep "pam_faillock.so" "$PAM_AUTH" | grep -q "unlock_time=0"; then
    echo "SUCCESS: Account lockout configured (3 failed attempts, admin unlock required)"
    echo "To unlock a locked user: sudo faillock --user <username> --reset"
    exit 0
else
    echo "ERROR: Failed to configure pam_faillock"
    exit 1
fi
