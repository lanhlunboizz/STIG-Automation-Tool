#!/bin/bash
# Common functions for remediation scripts
# Source this file at the beginning of remediation scripts that use apt-get

# Wait for dpkg lock to be released
wait_for_dpkg_lock() {
    local max_wait=120  # Maximum wait time in seconds
    local wait_interval=5  # Check every 5 seconds
    local waited=0
    
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1 || \
          fuser /var/cache/apt/archives/lock >/dev/null 2>&1; do
        
        if [ $waited -ge $max_wait ]; then
            echo "WARNING: dpkg lock held for too long (${max_wait}s), proceeding anyway..."
            return 1
        fi
        
        echo "Waiting for dpkg lock to be released... (${waited}s/${max_wait}s)"
        sleep $wait_interval
        waited=$((waited + wait_interval))
    done
    
    return 0
}

# Safe apt-get update with lock wait
safe_apt_update() {
    wait_for_dpkg_lock
    apt-get update -qq 2>&1 | tail -5
    return ${PIPESTATUS[0]}
}

# Safe apt-get install with lock wait
safe_apt_install() {
    wait_for_dpkg_lock
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$@" 2>&1 | tail -20
    return ${PIPESTATUS[0]}
}

# Export functions for use in scripts
export -f wait_for_dpkg_lock
export -f safe_apt_update
export -f safe_apt_install
