#!/bin/bash
# Check if automatic account locking after 30 days of inactivity is configured

USERADD_DEFAULTS="/etc/default/useradd"

if [ ! -f "$USERADD_DEFAULTS" ]; then
    echo "FAIL: $USERADD_DEFAULTS not found"
    exit 1
fi

# Check for INACTIVE=30 in /etc/default/useradd
if grep -qE "^INACTIVE=30" "$USERADD_DEFAULTS"; then
    echo "PASS: Automatic account locking after 30 days configured (INACTIVE=30)"
    exit 0
else
    current_value=$(grep "^INACTIVE=" "$USERADD_DEFAULTS" 2>/dev/null | cut -d= -f2)
    if [ -n "$current_value" ]; then
        echo "FAIL: INACTIVE is set to $current_value (should be 30)"
    else
        echo "FAIL: INACTIVE not configured in $USERADD_DEFAULTS"
    fi
    exit 1
fi
