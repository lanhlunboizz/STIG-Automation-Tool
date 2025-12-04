#!/bin/bash
# Remediation: Install and initialize AIDE
# Rule: UBTU-24-010007

echo "Installing and initializing AIDE..."

# Install AIDE
apt-get update
apt-get install -y aide aide-common

# Initialize AIDE database
echo "Initializing AIDE database (this may take several minutes)..."
aideinit

# Move new database to production
if [ -f /var/lib/aide/aide.db.new ]; then
    mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
fi

# Create cron job for daily AIDE checks
cat > /etc/cron.daily/aide-check <<'EOF'
#!/bin/bash
/usr/bin/aide --check | mail -s "AIDE Report for $(hostname)" root
EOF

chmod +x /etc/cron.daily/aide-check

echo "AIDE installed and initialized"
exit 0
