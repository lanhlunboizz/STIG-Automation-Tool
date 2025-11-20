#!/bin/bash
# Remediation: Install and configure rsyslog
# Rule: UBTU-24-100200

echo "Installing and configuring rsyslog..."

# Install rsyslog
apt-get update
apt-get install -y rsyslog

# Enable and start rsyslog
systemctl enable rsyslog
systemctl start rsyslog

# Configure rsyslog for failure events
cat >> /etc/rsyslog.d/50-default.conf <<'EOF'

# STIG UBTU-24-100200: Log failure events
auth,authpriv.*                 /var/log/auth.log
*.*;auth,authpriv.none          -/var/log/syslog
kern.*                          -/var/log/kern.log
*.emerg                         :omusrmsg:*
EOF

# Restart rsyslog
systemctl restart rsyslog

echo "rsyslog installed and configured"
exit 0
