#!/bin/bash
# Check: AIDE periodic check via cron
# Rule: UBTU-24-100120

if [ -f /etc/cron.daily/aide ] || [ -f /etc/cron.d/aide ]; then
    echo "PASS: AIDE cron job configured"
    exit 0
else
    echo "FAIL: AIDE cron job not found"
    exit 1
fi
