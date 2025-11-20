#!/bin/bash
# Check: Sudo logging
# Rule: UBTU-24-010012

SUDOERS_LOG="/etc/sudoers.d/audit_logs"

if [ -f "$SUDOERS_LOG" ]; then
    if grep -q "^Defaults.*logfile=" $SUDOERS_LOG; then
        echo "PASS: Sudo logging is configured"
        exit 0
    fi
fi

# Check main sudoers file
if grep -q "^Defaults.*logfile=" /etc/sudoers 2>/dev/null; then
    echo "PASS: Sudo logging is configured in /etc/sudoers"
    exit 0
fi

echo "FAIL: Sudo logging is not configured"
exit 1
