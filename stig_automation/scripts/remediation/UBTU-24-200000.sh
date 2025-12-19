#!/bin/bash
# Remediation: Configure concurrent session limit (maxlogins 10)

echo "Starting remediation: Configuring concurrent session limit..."

LIMITS_FILE="/etc/security/limits.d/50-maxlogins.conf"
LIMITS_DIR="/etc/security/limits.d"

# Create limits.d directory if not exists
if [ ! -d "$LIMITS_DIR" ]; then
    mkdir -p "$LIMITS_DIR"
    echo "Created directory: $LIMITS_DIR"
fi

# Check if already configured
if [ -f "$LIMITS_FILE" ] && grep -qE "^\*[[:space:]]+hard[[:space:]]+maxlogins[[:space:]]+10" "$LIMITS_FILE"; then
    echo "Concurrent session limit already configured"
    exit 0
fi

# Backup if file exists
if [ -f "$LIMITS_FILE" ]; then
    BACKUP_FILE="${LIMITS_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$LIMITS_FILE" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
fi

# Create or update configuration
echo "Configuring maxlogins limit..."
cat > "$LIMITS_FILE" << 'EOF'
# STIG UBTU-24-200000: Limit concurrent sessions to 10
# This prevents DoS attacks from excessive session creation
* hard maxlogins 10
EOF

# Set proper permissions
chmod 644 "$LIMITS_FILE"

# Verify configuration
if grep -qE "^\*[[:space:]]+hard[[:space:]]+maxlogins[[:space:]]+10" "$LIMITS_FILE"; then
    echo "SUCCESS: Concurrent session limit configured (maxlogins 10)"
    echo "NOTE: Users must log out and log back in for changes to take effect"
    exit 0
else
    echo "ERROR: Failed to configure concurrent session limit"
    exit 1
fi
