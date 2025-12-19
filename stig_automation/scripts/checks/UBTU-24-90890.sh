#!/bin/bash
# Check: AIDE rules for audit tools protection
# Rule: UBTU-24-90890
# Exit 0 if compliant, 1 if non-compliant

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "FAIL: AIDE configuration file not found"
    exit 1
fi

# Check for exactly these 6 audit tools with correct paths
REQUIRED_TOOLS=(
    "/sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512"
    "/sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512"
)

FAIL=0
for tool_line in "${REQUIRED_TOOLS[@]}"; do
    # Check if line exists and is not commented
    if ! grep -v "^#" "$AIDE_CONF" | grep -Fq "$tool_line"; then
        echo "FAIL: Missing or commented: $tool_line"
        FAIL=1
    fi
done

if [ $FAIL -eq 0 ]; then
    echo "PASS: All 6 audit tools are protected by AIDE"
    exit 0
else
    exit 1
fi
