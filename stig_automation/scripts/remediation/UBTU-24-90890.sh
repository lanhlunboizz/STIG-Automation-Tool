#!/bin/bash
# Remediation: Add AIDE rules for audit tools
# Rule: UBTU-24-90890

echo "Adding AIDE rules for audit tools protection..."

AIDE_CONF="/etc/aide/aide.conf"

# Install AIDE if not present
if [ ! -f "$AIDE_CONF" ]; then
    echo "AIDE not installed. Installing AIDE..."
    apt-get update -qq
    apt-get install -y aide aide-common
    
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
