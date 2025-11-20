#!/bin/bash
# Check: Minimum password age
# Rule: UBTU-24-010003

PASS_MIN_DAYS=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')

if [ -z "$PASS_MIN_DAYS" ]; then
    echo "FAIL: PASS_MIN_DAYS not set"
    exit 1
fi

if [ "$PASS_MIN_DAYS" -ge 1 ]; then
    echo "PASS: PASS_MIN_DAYS is $PASS_MIN_DAYS (compliant)"
    exit 0
else
    echo "FAIL: PASS_MIN_DAYS is $PASS_MIN_DAYS (must be >= 1)"
    exit 1
fi
