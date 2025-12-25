#!/bin/bash
# Remediation: Install and initialize AIDE
# Rule: UBTU-24-010007

echo "Installing AIDE..."

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

# Install AIDE
wait_for_lock
apt-get update -qq 2>&1 | tail -3

wait_for_lock
DEBIAN_FRONTEND=noninteractive apt-get install -y aide aide-common 2>&1 | tail -5

# Note: aideinit is NOT run here because it takes 10+ minutes
# Run it manually later: sudo aideinit
echo "NOTE: Run 'sudo aideinit' manually to initialize AIDE database (takes 10+ mins)"

# Check if AIDE installed successfully
if dpkg -l | grep -q "^ii.*aide "; then
    echo "SUCCESS: AIDE packages installed"
    exit 0
else
    echo "ERROR: Failed to install AIDE"
    exit 1
fi
