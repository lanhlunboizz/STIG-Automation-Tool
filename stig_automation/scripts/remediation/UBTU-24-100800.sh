#!/bin/bash
# Remediation: Install SSH meta-package

echo "Starting remediation: Installing ssh meta-package..."

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

# Check if all required packages are already installed
if dpkg -l | grep -q "^ii.*openssh-client" && \
   dpkg -l | grep -q "^ii.*openssh-server" && \
   dpkg -l | grep -q "^ii.*openssh-sftp-server"; then
    echo "All openssh packages are already installed"
    exit 0
fi

# Update package list and install ssh meta-package
echo "Installing ssh meta-package..."
wait_for_lock
apt-get update -qq 2>&1 | tail -3

wait_for_lock
DEBIAN_FRONTEND=noninteractive apt-get install -y ssh 2>&1 | tail -5

# Verify installation
if dpkg -l | grep -q "^ii.*openssh-client" && \
   dpkg -l | grep -q "^ii.*openssh-server" && \
   dpkg -l | grep -q "^ii.*openssh-sftp-server"; then
    echo "SUCCESS: ssh meta-package installed successfully"
    echo "Installed: openssh-client, openssh-server, openssh-sftp-server"
    exit 0
else
    echo "ERROR: Failed to install all required openssh packages"
    exit 1
fi
