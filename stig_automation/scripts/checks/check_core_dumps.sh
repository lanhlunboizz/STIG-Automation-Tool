#!/bin/bash
# Check: Core dumps restricted
# Rule: UBTU-24-010011

LIMITS_CONF="/etc/security/limits.conf"
SYSCTL_CONF="/etc/sysctl.conf"

FAIL=0

# Check limits.conf
if ! grep -q "^\*.*hard.*core.*0" $LIMITS_CONF 2>/dev/null; then
    echo "FAIL: Core dump limit not set in $LIMITS_CONF"
    FAIL=1
fi

# Check sysctl
SUID_DUMPABLE=$(sysctl fs.suid_dumpable 2>/dev/null | awk '{print $3}')
if [ "$SUID_DUMPABLE" != "0" ]; then
    echo "FAIL: fs.suid_dumpable not set to 0"
    FAIL=1
fi

if [ $FAIL -eq 0 ]; then
    echo "PASS: Core dumps are properly restricted"
    exit 0
else
    exit 1
fi
