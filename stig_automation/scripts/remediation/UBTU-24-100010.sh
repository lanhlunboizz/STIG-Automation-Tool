#!/bin/bash
# Remediation: Remove systemd-timesyncd and install chrony
# Rule: UBTU-24-100010

# Function to wait for dpkg lock
wait_for_lock() {
    local max_wait=60
    local waited=0
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        if [ $waited -ge $max_wait ]; then
            echo "WARNING: dpkg lock timeout"
            return 1
        fi
        sleep 3
        waited=$((waited + 3))
    done
    return 0
}

echo "Removing systemd-timesyncd and installing chrony..."

# Remove systemd-timesyncd
wait_for_lock
DEBIAN_FRONTEND=noninteractive apt-get purge -y systemd-timesyncd 2>&1 | tail -5

# Install chrony as replacement
wait_for_lock
apt-get update -qq 2>&1 | tail -3

wait_for_lock
DEBIAN_FRONTEND=noninteractive apt-get install -y chrony 2>&1 | tail -5

# Enable and start chrony
systemctl enable chrony 2>/dev/null || true
systemctl start chrony 2>/dev/null || true

echo "systemd-timesyncd removed, chrony installed"
exit 0
