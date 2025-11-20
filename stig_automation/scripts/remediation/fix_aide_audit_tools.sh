#!/bin/bash
# Remediation: Add AIDE rules for audit tools
# Rule: UBTU-24-90890

echo "Adding AIDE rules for audit tools protection..."

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "ERROR: AIDE not installed. Install AIDE first."
    exit 1
fi

# Backup
cp "$AIDE_CONF" "${AIDE_CONF}.bak.$(date +%Y%m%d_%H%M%S)"

# Add audit tools monitoring
cat >> "$AIDE_CONF" <<'EOF'

# STIG UBTU-24-90890: Monitor audit tools
/usr/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512
/usr/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512
EOF

# Reinitialize AIDE database
echo "Reinitializing AIDE database..."
aideinit
if [ -f /var/lib/aide/aide.db.new ]; then
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
fi

echo "Audit tools protection configured"
exit 0
