#!/bin/bash
# Check: Maximum password age
# Rule: UBTU-24-010004

PASS_MAX_DAYS=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')

if [ -z "$PASS_MAX_DAYS" ]; then
    echo "FAIL: PASS_MAX_DAYS not set"
    exit 1
fi

if [ "$PASS_MAX_DAYS" -le 60 ] && [ "$PASS_MAX_DAYS" -gt 0 ]; then
    echo "PASS: PASS_MAX_DAYS is $PASS_MAX_DAYS (compliant)"
    exit 0
else
    echo "FAIL: PASS_MAX_DAYS is $PASS_MAX_DAYS (must be <= 60)"
    exit 1
fi
