#!/bin/bash
# Check: auditd enabled and active
# Rule: UBTU-24-100410

if ! command -v auditd &> /dev/null; then
    echo "FAIL: auditd is not installed"
    exit 1
fi

# Check if enabled
if systemctl is-enabled --quiet auditd 2>/dev/null; then
    ENABLED="yes"
else
    ENABLED="no"
fi

# Check if active
if systemctl is-active --quiet auditd 2>/dev/null; then
    ACTIVE="yes"
else
    ACTIVE="no"
fi

if [ "$ENABLED" = "yes" ] && [ "$ACTIVE" = "yes" ]; then
    echo "PASS: auditd is enabled and active"
    exit 0
else
    echo "FAIL: auditd enabled=$ENABLED, active=$ACTIVE"
    exit 1
fi
