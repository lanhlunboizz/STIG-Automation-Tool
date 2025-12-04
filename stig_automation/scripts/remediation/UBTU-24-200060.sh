#!/bin/bash
# Remediation: Configure automatic session timeout (TMOUT=600)

echo "Starting remediation: Configuring automatic session timeout..."

TIMEOUT_CONFIG="/etc/profile.d/autologout.sh"
TMOUT_VALUE=600

# Check if already configured
if grep -rq "^[[:space:]]*TMOUT=600" /etc/profile.d/ 2>/dev/null || \
   grep -q "^[[:space:]]*TMOUT=600" /etc/bash.bashrc 2>/dev/null; then
    echo "Automatic session timeout is already configured"
    exit 0
fi

# Create configuration file in /etc/profile.d/
echo "Creating $TIMEOUT_CONFIG..."
cat > "$TIMEOUT_CONFIG" << 'EOF'
#!/bin/bash
# STIG UBTU-24-200060: Automatic session timeout after 10 minutes
# Terminate inactive shell sessions after 600 seconds (10 minutes)

TMOUT=600
readonly TMOUT
export TMOUT
EOF

# Set proper permissions
chmod 644 "$TIMEOUT_CONFIG"

echo "Configuration file created: $TIMEOUT_CONFIG"

# Verify configuration
if [ -f "$TIMEOUT_CONFIG" ] && grep -q "TMOUT=600" "$TIMEOUT_CONFIG"; then
    echo "SUCCESS: Automatic session timeout configured (TMOUT=600)"
    echo "NOTE: Users must log out and log back in for changes to take effect"
    exit 0
else
    echo "ERROR: Failed to configure automatic session timeout"
    exit 1
fi
