#!/bin/bash
# Remediation: Configure AIDE periodic checks
# Rule: UBTU-24-100120

echo "Configuring AIDE periodic checks..."

# Create cron job for daily AIDE checks
cat > /etc/cron.daily/aide <<'EOF'
#!/bin/bash
# Daily AIDE integrity check

/usr/bin/aide --check > /var/log/aide/aide_check_$(date +%Y%m%d).log 2>&1

# Send email if changes detected (optional)
if [ $? -ne 0 ]; then
    echo "AIDE detected changes. Check /var/log/aide/ for details."
fi
EOF

chmod +x /etc/cron.daily/aide

# Create log directory
mkdir -p /var/log/aide

echo "AIDE periodic checks configured"
exit 0
