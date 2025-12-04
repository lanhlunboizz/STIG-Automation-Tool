#!/bin/bash
# Remediation: Enable and start auditd
# Rule: UBTU-24-100410

echo "Enabling and starting auditd..."

if ! command -v auditd &> /dev/null; then
    echo "ERROR: auditd is not installed"
    exit 1
fi

# Enable auditd
systemctl enable auditd

# Start auditd
systemctl start auditd

# Verify
if systemctl is-enabled --quiet auditd && systemctl is-active --quiet auditd; then
    echo "auditd enabled and started successfully"
    exit 0
else
    echo "ERROR: Failed to enable/start auditd"
    systemctl status auditd
    exit 1
fi
