#!/bin/bash
# Check if pam_faillock is configured with deny=3 and unlock_time=0

PAM_AUTH="/etc/pam.d/common-auth"

if [ ! -f "$PAM_AUTH" ]; then
    echo "FAIL: $PAM_AUTH not found"
    exit 1
fi

# Check for pam_faillock with deny=3
if ! grep -q "pam_faillock.so" "$PAM_AUTH"; then
    echo "FAIL: pam_faillock.so not configured"
    exit 1
fi

# Check deny=3 parameter
if ! grep "pam_faillock.so" "$PAM_AUTH" | grep -q "deny=3"; then
    echo "FAIL: pam_faillock deny parameter not set to 3"
    exit 1
fi

# Check unlock_time=0 parameter
if ! grep "pam_faillock.so" "$PAM_AUTH" | grep -q "unlock_time=0"; then
    echo "FAIL: pam_faillock unlock_time not set to 0 (admin unlock required)"
    exit 1
fi

echo "PASS: Account lockout after 3 failed attempts configured (unlock_time=0)"
exit 0
