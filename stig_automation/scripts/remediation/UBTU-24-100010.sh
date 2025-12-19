#!/bin/bash
# Remediation: Remove systemd-timesyncd and install chrony
# Rule: UBTU-24-100010

echo "Removing systemd-timesyncd and installing chrony..."

# Remove systemd-timesyncd
echo "Removing systemd-timesyncd..."
DEBIAN_FRONTEND=noninteractive apt-get purge -y systemd-timesyncd 2>&1 | tail -5

# Verify removal
if dpkg -l | grep -q "^ii.*systemd-timesyncd"; then
    echo "WARNING: systemd-timesyncd still installed after purge attempt"
    echo "Attempting autoremove..."
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y systemd-timesyncd 2>&1 | tail -5
fi

# Install chrony as replacement
if ! dpkg -l | grep -q "^ii.*chrony"; then
    echo "Installing chrony..."
    apt-get update -qq 2>&1 | tail -5
    DEBIAN_FRONTEND=noninteractive apt-get install -y chrony 2>&1 | tail -5
fi

# Enable and start chrony
systemctl enable chrony 2>/dev/null || true
systemctl start chrony 2>/dev/null || true

echo "Remediation complete"
exit 0
