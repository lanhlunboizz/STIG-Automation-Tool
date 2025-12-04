#!/bin/bash
# Check if automatic session timeout is configured (TMOUT=600 for 10 minutes)

# Check in /etc/profile.d/ directory
if grep -rq "^[[:space:]]*TMOUT=600" /etc/profile.d/ 2>/dev/null; then
    echo "PASS: Automatic session timeout configured in /etc/profile.d/"
    exit 0
fi

# Check in /etc/bash.bashrc
if [ -f /etc/bash.bashrc ] && grep -q "^[[:space:]]*TMOUT=600" /etc/bash.bashrc; then
    echo "PASS: Automatic session timeout configured in /etc/bash.bashrc"
    exit 0
fi

# Check in /etc/profile
if [ -f /etc/profile ] && grep -q "^[[:space:]]*TMOUT=600" /etc/profile; then
    echo "PASS: Automatic session timeout configured in /etc/profile"
    exit 0
fi

echo "FAIL: Automatic session timeout (TMOUT=600) NOT configured"
exit 1
