#!/bin/bash
# Remediation: Install auditd
# Rule: UBTU-24-100400

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

echo "Installing auditd..."

wait_for_lock
apt-get update -qq 2>&1 | tail -3

wait_for_lock
DEBIAN_FRONTEND=noninteractive apt-get install -y auditd audispd-plugins 2>&1 | tail -5

if dpkg -l | grep -q "^ii.*auditd "; then
    echo "SUCCESS: auditd installed"
    exit 0
else
    echo "ERROR: Failed to install auditd"
    exit 1
fi
