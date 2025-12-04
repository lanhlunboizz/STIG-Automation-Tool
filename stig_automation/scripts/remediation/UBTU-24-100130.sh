#!/bin/bash
# Remediation: Configure AIDE alerts
# Rule: UBTU-24-100130

echo "Configuring AIDE alerts..."

AIDE_CONF="/etc/aide/aide.conf"

if [ ! -f "$AIDE_CONF" ]; then
    echo "ERROR: AIDE not configured"
    exit 1
fi

# Backup
cp "$AIDE_CONF" "${AIDE_CONF}.bak.$(date +%Y%m%d_%H%M%S)"

# Configure email reporting
if ! grep -q "^report_url=" "$AIDE_CONF"; then
    echo "report_url=stdout" >> "$AIDE_CONF"
fi

# Ensure cron job sends email
cat > /etc/cron.daily/aide <<'EOF'
#!/bin/bash
# Daily AIDE check with email alert

AIDE_OUTPUT=$(/usr/bin/aide --check 2>&1)
EXIT_CODE=$?

# Log output
echo "$AIDE_OUTPUT" > /var/log/aide/aide_check_$(date +%Y%m%d).log

# Send alert if changes detected
if [ $EXIT_CODE -ne 0 ]; then
    echo "AIDE Integrity Check Alert - $(date)" | mail -s "AIDE Alert: Changes Detected" root
    echo "$AIDE_OUTPUT" | mail -s "AIDE Report - $(date)" root
fi
EOF

chmod +x /etc/cron.daily/aide

echo "AIDE alerts configured"
exit 0
