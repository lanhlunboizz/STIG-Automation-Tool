#!/bin/bash
# Remediation: Remove systemd-timesyncd and install chrony
# Rule: UBTU-24-100010

echo "Removing systemd-timesyncd and installing chrony..."

# Remove systemd-timesyncd
apt-get purge -y systemd-timesyncd

# Install chrony as replacement
apt-get update
apt-get install -y chrony

# Enable and start chrony
systemctl enable chrony
systemctl start chrony

echo "systemd-timesyncd removed, chrony installed"
exit 0
