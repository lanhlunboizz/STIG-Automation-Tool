#!/bin/bash
# Remediation: Configure APT to prevent unauthorized package installation

echo "Starting remediation: Configuring APT package installation controls..."

APT_AUTO_CONF="/etc/apt/apt.conf.d/20auto-upgrades"
APT_DIR="/etc/apt/apt.conf.d"

# Create directory if not exists
if [ ! -d "$APT_DIR" ]; then
    mkdir -p "$APT_DIR"
fi

# Backup if file exists
if [ -f "$APT_AUTO_CONF" ]; then
    BACKUP_FILE="${APT_AUTO_CONF}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$APT_AUTO_CONF" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
fi

# Disable automatic package updates
echo "Disabling automatic package installation..."
cat > "$APT_AUTO_CONF" << 'EOF'
// STIG UBTU-24-300001: Prevent automatic package installation
// Manual control required for all package installations
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
EOF

# Set proper permissions
chmod 644 "$APT_AUTO_CONF"

# Verify configuration
if grep -q "APT::Periodic::Update-Package-Lists \"0\"" "$APT_AUTO_CONF" && \
   grep -q "APT::Periodic::Unattended-Upgrade \"0\"" "$APT_AUTO_CONF"; then
    echo "SUCCESS: APT automatic package installation disabled"
    echo "NOTE: All package installations now require manual approval"
    exit 0
else
    echo "ERROR: Failed to configure APT"
    exit 1
fi
