#!/bin/bash
# Check if concurrent session limit (maxlogins) is configured

LIMITS_FILE="/etc/security/limits.d/50-maxlogins.conf"
LIMITS_CONF="/etc/security/limits.conf"

# Check in limits.d directory first
if [ -f "$LIMITS_FILE" ] && grep -qE "^\*[[:space:]]+hard[[:space:]]+maxlogins[[:space:]]+10" "$LIMITS_FILE"; then
    echo "PASS: Concurrent session limit configured in $LIMITS_FILE"
    exit 0
fi

# Check in main limits.conf
if [ -f "$LIMITS_CONF" ] && grep -qE "^\*[[:space:]]+hard[[:space:]]+maxlogins[[:space:]]+10" "$LIMITS_CONF"; then
    echo "PASS: Concurrent session limit configured in $LIMITS_CONF"
    exit 0
fi

echo "FAIL: Concurrent session limit (maxlogins 10) NOT configured"
exit 1
