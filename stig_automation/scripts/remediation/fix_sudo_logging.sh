#!/bin/bash
# Remediation: Configure sudo logging
# Rule: UBTU-24-010012

echo "Configuring sudo logging..."

SUDOERS_LOG="/etc/sudoers.d/audit_logs"

# Create log directory
mkdir -p /var/log/sudo

# Configure sudo logging
cat > $SUDOERS_LOG <<EOF
# STIG Requirement: Log all sudo commands
Defaults logfile="/var/log/sudo/sudo.log"
Defaults log_input,log_output
EOF

chmod 0440 $SUDOERS_LOG

echo "Sudo logging configured at /var/log/sudo/sudo.log"
exit 0
