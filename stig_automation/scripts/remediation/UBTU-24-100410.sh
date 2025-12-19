#!/bin/bash
# Remediation: Enable and start auditd
# Rule: UBTU-24-100410

echo "Enabling and starting auditd..."

if ! command -v auditd &> /dev/null; then
    echo "ERROR: auditd is not installed. Install it first (UBTU-24-100400)"
    exit 1
fi

# Wait for auditd to be available
sleep 2

# Enable auditd
echo "Enabling auditd service..."
systemctl enable auditd 2>&1 | tail -3

# Start auditd
echo "Starting auditd service..."
systemctl start auditd 2>&1 | tail -3

# Wait for service to stabilize
sleep 2

# Verify
if systemctl is-enabled --quiet auditd 2>/dev/null && systemctl is-active --quiet auditd 2>/dev/null; then
    echo "SUCCESS: auditd enabled and active"
    exit 0
else
    echo "ERROR: Failed to enable/start auditd"
    echo "Status: enabled=$(systemctl is-enabled auditd 2>&1), active=$(systemctl is-active auditd 2>&1)"
    exit 1
fi
