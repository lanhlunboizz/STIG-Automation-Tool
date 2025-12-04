#!/bin/bash
# Check: AIDE periodic check via cron
# Rule: UBTU-24-100120

# Check for AIDE cron job
if [ -f /etc/cron.daily/aide ] && [ -x /etc/cron.daily/aide ]; then
    echo "PASS: AIDE cron job configured and executable"
    exit 0
elif [ -f /etc/cron.d/aide ]; then
    echo "PASS: AIDE cron job configured in cron.d"
    exit 0
else
    echo "FAIL: AIDE cron job not found or not executable"
    ls -la /etc/cron.daily/aide 2>&1 || echo "File does not exist"
    exit 1
fi
