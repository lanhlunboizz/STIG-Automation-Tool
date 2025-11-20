#!/bin/bash
# Check: AIDE alert configuration
# Rule: UBTU-24-100130

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "FAIL: AIDE not configured"
    exit 1
fi

# Check if mail alerts are configured
if grep -q "^report_url=" "$AIDE_CONF" || [ -f /etc/cron.daily/aide ]; then
    echo "PASS: AIDE alerts configured"
    exit 0
else
    echo "FAIL: AIDE alerts not configured"
    exit 1
fi
