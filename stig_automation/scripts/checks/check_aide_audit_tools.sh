#!/bin/bash
# Check: AIDE rules for audit tools protection
# Rule: UBTU-24-90890
# Exit 0 if compliant, 1 if non-compliant

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "FAIL: AIDE configuration file not found"
    exit 1
fi

# Check if audit tools are monitored by AIDE
# Looking for patterns that include audit tool paths
if grep -q "/usr/sbin/audit" "$AIDE_CONF"; then
    echo "PASS: Audit tools are protected by AIDE"
    exit 0
fi

# Detailed check
AUDIT_TOOLS=("/usr/sbin/auditctl" "/usr/sbin/auditd" "/usr/sbin/ausearch" "/usr/sbin/aureport")
FAIL=0

for tool in "${AUDIT_TOOLS[@]}"; do
    if ! grep -q "$tool" "$AIDE_CONF"; then
        echo "FAIL: $tool not monitored by AIDE"
        FAIL=1
    fi
done

if [ $FAIL -eq 0 ]; then
    echo "PASS: Audit tools are protected by AIDE"
    exit 0
else
    exit 1
fi
