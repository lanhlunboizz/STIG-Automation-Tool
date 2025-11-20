#!/bin/bash
# Remediation: Install and enable auditd
# Rule: UBTU-24-010008

echo "Installing and enabling auditd..."

# Install auditd
apt-get update
apt-get install -y auditd audispd-plugins

# Enable and start auditd
systemctl enable auditd
systemctl start auditd

# Basic audit rules
cat > /etc/audit/rules.d/stig.rules <<'EOF'
# STIG Audit Rules
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k actions
-w /var/log/sudo.log -p wa -k actions
EOF

# Reload rules
augenrules --load

echo "Auditd installed and configured"
exit 0
