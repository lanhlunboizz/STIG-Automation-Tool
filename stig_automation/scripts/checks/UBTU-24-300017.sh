#!/bin/bash
# Check if pam_faildelay is configured with 4 second delay

PAM_AUTH="/etc/pam.d/common-auth"

if [ ! -f "$PAM_AUTH" ]; then
    echo "FAIL: $PAM_AUTH not found"
    exit 1
fi

# Check for pam_faildelay with delay=4000000 (4 seconds in microseconds)
if grep -qE "^auth[[:space:]]+required[[:space:]]+pam_faildelay.so[[:space:]]+delay=4000000" "$PAM_AUTH"; then
    echo "PASS: Login delay of 4 seconds configured after failed attempts"
    exit 0
else
    echo "FAIL: pam_faildelay with 4 second delay NOT configured"
    exit 1
fi
