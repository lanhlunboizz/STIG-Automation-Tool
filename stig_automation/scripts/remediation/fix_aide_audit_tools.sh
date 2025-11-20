#!/bin/bash
# Remediation: Add AIDE rules for audit tools
# Rule: UBTU-24-90890

echo "Adding AIDE rules for audit tools protection..."

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "ERROR: AIDE not installed. Install AIDE first."
    exit 1
fi

# Create log directory with proper permissions
mkdir -p /var/log/aide
chmod 755 /var/log/aide

# Create lib directory with proper permissions
mkdir -p /var/lib/aide
chmod 755 /var/lib/aide

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
echo "Reinitializing AIDE database (this may take a few minutes)..."
aideinit 2>&1

# Wait for completion
sleep 2

if [ -f /var/lib/aide/aide.db.new ]; then
    mv -f /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    echo "Audit tools protection configured and AIDE database updated"
    exit 0
elif [ -f /var/lib/aide/aide.db.new.gz ]; then
    mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    echo "Audit tools protection configured and AIDE database updated"
    exit 0
else
    echo "WARNING: AIDE database update may still be running"
    exit 0
fi
