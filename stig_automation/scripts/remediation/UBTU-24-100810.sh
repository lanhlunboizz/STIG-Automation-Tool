#!/bin/bash
# Remediation: Enable and start SSH service

echo "Starting remediation: Enabling SSH service..."

# Check if openssh-server is installed
if ! dpkg -l | grep -q "^ii.*openssh-server"; then
    echo "ERROR: openssh-server not installed. Install it first (UBTU-24-100800)"
    exit 1
fi

# Wait a moment for SSH service to be available after installation
sleep 2

# Detect SSH service name (ssh.service or sshd.service)
if systemctl list-unit-files | grep -q "^ssh.service"; then
    SSH_SERVICE="ssh.service"
elif systemctl list-unit-files | grep -q "^sshd.service"; then
    SSH_SERVICE="sshd.service"
else
    echo "ERROR: SSH service not found"
    exit 1
fi

echo "Detected SSH service: $SSH_SERVICE"

# Check if service is already enabled and active
enabled_status=$(systemctl is-enabled $SSH_SERVICE 2>/dev/null || echo "disabled")
active_status=$(systemctl is-active $SSH_SERVICE 2>/dev/null || echo "inactive")

echo "Current status - enabled: $enabled_status, active: $active_status"

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "SSH service is already enabled and active"
    exit 0
fi

# Enable SSH service
if [ "$enabled_status" != "enabled" ]; then
    echo "Enabling $SSH_SERVICE..."
    if systemctl enable $SSH_SERVICE 2>&1; then
        echo "Successfully enabled $SSH_SERVICE"
    else
        echo "Failed to enable $SSH_SERVICE"
        exit 1
    fi
fi

# Start SSH service if not active
if [ "$active_status" != "active" ]; then
    echo "Starting $SSH_SERVICE..."
    if systemctl start $SSH_SERVICE 2>&1; then
        echo "Successfully started $SSH_SERVICE"
    else
        echo "Failed to start $SSH_SERVICE"
        exit 1
    fi
fi

# Wait for service to stabilize
sleep 2

# Verify service status
enabled_status=$(systemctl is-enabled $SSH_SERVICE 2>/dev/null || echo "unknown")
active_status=$(systemctl is-active $SSH_SERVICE 2>/dev/null || echo "unknown")

if [ "$enabled_status" = "enabled" ] && [ "$active_status" = "active" ]; then
    echo "SUCCESS: SSH service is now enabled and active"
    exit 0
else
    echo "ERROR: Failed to enable/start SSH service - enabled: $enabled_status, active: $active_status"
    exit 1
fi
