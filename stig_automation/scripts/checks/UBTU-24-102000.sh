#!/bin/bash
# Check if GRUB is configured to require authentication for single-user mode

GRUB_CONFIG="/boot/grub/grub.cfg"

if [ ! -f "$GRUB_CONFIG" ]; then
    echo "FAIL: $GRUB_CONFIG not found"
    exit 1
fi

# Check for password_pbkdf2 entry in grub.cfg
if grep -q "password_pbkdf2" "$GRUB_CONFIG"; then
    echo "PASS: GRUB configured with password authentication for single-user mode"
    exit 0
else
    echo "FAIL: GRUB NOT configured with password authentication"
    exit 1
fi
