#!/bin/bash
# Check: SSH root login disabled
# Rule: UBTU-24-010006

SSHD_CONFIG="/etc/ssh/sshd_config"

if [ ! -f "$SSHD_CONFIG" ]; then
    echo "FAIL: $SSHD_CONFIG not found"
    exit 1
fi

PERMIT_ROOT=$(grep "^PermitRootLogin" $SSHD_CONFIG | awk '{print $2}')

if [ -z "$PERMIT_ROOT" ]; then
    echo "FAIL: PermitRootLogin not explicitly configured"
    exit 1
fi

if [ "$PERMIT_ROOT" = "no" ]; then
    echo "PASS: Root login via SSH is disabled"
    exit 0
else
    echo "FAIL: Root login via SSH is enabled ($PERMIT_ROOT)"
    exit 1
fi
