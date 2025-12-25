#!/bin/bash
# Remediation: Add AIDE rules for audit tools
# Rule: UBTU-24-90890

# Source common functions
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/common.sh" ]; then
    source "$SCRIPT_DIR/common.sh"
fi

# Function to wait for dpkg lock (inline if common.sh not available)
wait_for_lock() {
    local max_wait=60
    local waited=0
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        if [ $waited -ge $max_wait ]; then
            echo "WARNING: dpkg lock timeout"
            return 1
        fi
        sleep 3
        waited=$((waited + 3))
    done
    return 0
}

echo "Adding AIDE rules for audit tools protection..."

AIDE_CONF="/etc/aide/aide.conf"

# Install AIDE if not present
if [ ! -f "$AIDE_CONF" ]; then
    echo "AIDE not installed. Installing AIDE..."
    
    # Wait for any existing apt processes
    wait_for_lock
    
    apt-get update -qq 2>&1 | tail -3
    
    wait_for_lock
    DEBIAN_FRONTEND=noninteractive apt-get install -y aide aide-common 2>&1 | tail -5
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install AIDE"
        exit 1
    fi
    
    echo "AIDE installed successfully"
fi

# Backup configuration file
cp "$AIDE_CONF" "${AIDE_CONF}.bak.$(date +%Y%m%d_%H%M%S)"

# Add audit tools monitoring rules
cat >> "$AIDE_CONF" <<'EOF'

# STIG UBTU-24-90890: Monitor audit tools
/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512
EOF

echo "Audit tools protection rules added to AIDE configuration"
exit 0
