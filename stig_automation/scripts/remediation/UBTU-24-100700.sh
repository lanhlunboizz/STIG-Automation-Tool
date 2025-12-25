#!/bin/bash
# Remediation: Install chrony package

echo "Starting remediation: Installing chrony package..."

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

# Check if already installed
if dpkg -l | grep -q "^ii.*chrony "; then
    echo "chrony package is already installed"
    exit 0
fi

# Wait for dpkg lock and install chrony
echo "Installing chrony..."
wait_for_lock
apt-get update -qq 2>&1 | tail -3

wait_for_lock
DEBIAN_FRONTEND=noninteractive apt-get install -y chrony 2>&1 | tail -5

# Verify installation
if dpkg -l | grep -q "^ii.*chrony "; then
    echo "SUCCESS: chrony package installed successfully"
    
    # Ensure chrony service is enabled and started
    echo "Enabling and starting chrony service..."
    systemctl enable chrony 2>/dev/null || true
    systemctl start chrony 2>/dev/null || true
    
    # Give service time to start
    sleep 2
    
    # Check if service is running (non-blocking check)
    if systemctl is-active chrony >/dev/null 2>&1; then
        echo "Chrony service is active"
    else
        echo "Warning: chrony service may not be active, but package is installed"
    fi
    
    exit 0
else
    echo "ERROR: Failed to install chrony package"
    exit 1
fi
