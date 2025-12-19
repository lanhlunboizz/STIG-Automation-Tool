#!/bin/bash
# Remediation: Install sssd, libpam-sss, and libnss-sss packages

set -e

echo "Starting remediation: Installing SSSD packages..."

# Check which packages need to be installed
packages_to_install=()

if ! dpkg -l | grep -q "^ii.*sssd "; then
    packages_to_install+=("sssd")
fi

if ! dpkg -l | grep -q "^ii.*libpam-sss"; then
    packages_to_install+=("libpam-sss")
fi

if ! dpkg -l | grep -q "^ii.*libnss-sss"; then
    packages_to_install+=("libnss-sss")
fi

# If all packages are already installed, exit
if [ ${#packages_to_install[@]} -eq 0 ]; then
    echo "All SSSD packages are already installed"
    exit 0
fi

# Update package list and install missing packages
echo "Installing packages: ${packages_to_install[*]}..."
apt-get update -qq
apt-get install -y "${packages_to_install[@]}"

# Verify installation
missing_packages=()
if ! dpkg -l | grep -q "^ii.*sssd "; then
    missing_packages+=("sssd")
fi
if ! dpkg -l | grep -q "^ii.*libpam-sss"; then
    missing_packages+=("libpam-sss")
fi
if ! dpkg -l | grep -q "^ii.*libnss-sss"; then
    missing_packages+=("libnss-sss")
fi

if [ ${#missing_packages[@]} -eq 0 ]; then
    echo "SUCCESS: All SSSD packages installed successfully"
    
    # CRITICAL: Create minimal safe SSSD config to prevent auth lockout
    SSSD_CONF="/etc/sssd/sssd.conf"
    if [ ! -f "$SSSD_CONF" ]; then
        echo "Creating minimal safe SSSD configuration..."
        mkdir -p /etc/sssd
        cat > "$SSSD_CONF" <<'EOF'
[sssd]
services = nss, pam
domains = LOCAL

[domain/LOCAL]
id_provider = files
EOF
        chmod 600 "$SSSD_CONF"
        echo "Minimal SSSD config created at $SSSD_CONF"
    fi
    
    exit 0
else
    echo "ERROR: Failed to install packages: ${missing_packages[*]}"
    exit 1
fi
