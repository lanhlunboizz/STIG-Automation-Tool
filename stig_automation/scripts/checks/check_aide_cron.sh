#!/bin/bash
# Check: AIDE periodic check via cron
# Rule: UBTU-24-100120

# Check for AIDE cron job
if [ -f /etc/cron.daily/aide ]; then
    if [ -x /etc/cron.daily/aide ]; then
        echo "PASS: AIDE cron job configured and executable"
        exit 0
    else
        echo "FAIL: AIDE cron job exists but not executable"
        exit 1
    fi
elif [ -f /etc/cron.d/aide ]; then
    echo "PASS: AIDE cron job configured in cron.d"
    exit 0
else
    echo "FAIL: AIDE cron job not found"
    exit 1
fi
