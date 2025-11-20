#!/bin/bash
# Check: Account inactivity timeout
# Rule: UBTU-24-010001
# Exit 0 if compliant, 1 if non-compliant

# Kiểm tra INACTIVE setting trong /etc/default/useradd
INACTIVE=$(grep "^INACTIVE" /etc/default/useradd 2>/dev/null | cut -d= -f2)

if [ -z "$INACTIVE" ]; then
    echo "FAIL: INACTIVE not set in /etc/default/useradd"
    exit 1
fi

if [ "$INACTIVE" -le 35 ] && [ "$INACTIVE" -ge 0 ]; then
    echo "PASS: INACTIVE is set to $INACTIVE days (compliant)"
    exit 0
else
    echo "FAIL: INACTIVE is set to $INACTIVE days (must be <= 35)"
    exit 1
fi
