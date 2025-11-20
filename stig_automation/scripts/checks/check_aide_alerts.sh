#!/bin/bash
# Check: AIDE alert configuration
# Rule: UBTU-24-100130

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "FAIL: AIDE not configured"
    exit 1
fi

# Check if cron job exists with mail functionality
if [ -f /etc/cron.daily/aide ]; then
    if grep -q "mail" /etc/cron.daily/aide; then
        echo "PASS: AIDE alerts configured via cron"
        exit 0
    fi
fi

# Check if report_url is configured
if grep -q "^report_url=" "$AIDE_CONF"; then
    echo "PASS: AIDE alerts configured via report_url"
    exit 0
fi

echo "FAIL: AIDE alerts not configured"
exit 1
