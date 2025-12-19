#!/bin/bash
# Remediation: Configure GRUB to require authentication for single-user mode

echo "Starting remediation: Configuring GRUB password authentication..."

GRUB_CONFIG="/etc/grub.d/40_custom"
GRUB_MAIN="/boot/grub/grub.cfg"

# Check if already configured
if [ -f "$GRUB_MAIN" ] && grep -q "password_pbkdf2" "$GRUB_MAIN"; then
    echo "GRUB password authentication is already configured"
    exit 0
fi

echo ""
echo "=========================================="
echo "IMPORTANT: Manual GRUB Password Required"
echo "=========================================="
echo ""
echo "STIG UBTU-24-102000 requires manual configuration:"
echo ""
echo "Step 1: Generate encrypted password"
echo "  $ sudo grub-mkpasswd-pbkdf2"
echo "  Enter Password: [your password]"
echo "  Reenter Password: [your password]"
echo "  Output: grub.pbkdf2.sha512.10000.HASH..."
echo ""
echo "Step 2: Configure GRUB with the hash"
echo "  $ sudo sed -i '\$i set superusers=\"root\"' /etc/grub.d/40_custom"
echo "  $ sudo sed -i '\$i password_pbkdf2 root <HASH>' /etc/grub.d/40_custom"
echo "  (Replace <HASH> with the output from Step 1)"
echo ""
echo "Step 3: Update GRUB configuration"
echo "  $ sudo update-grub"
echo ""
echo "Step 4: Verify"
echo "  $ sudo grep password_pbkdf2 /boot/grub/grub.cfg"
echo ""

# Create a template in 40_custom if not exists
if [ -f "$GRUB_CONFIG" ]; then
    if ! grep -q "set superusers" "$GRUB_CONFIG"; then
        echo "" >> "$GRUB_CONFIG"
        echo "# STIG UBTU-24-102000: GRUB password authentication" >> "$GRUB_CONFIG"
        echo "# Generate hash: grub-mkpasswd-pbkdf2" >> "$GRUB_CONFIG"
        echo "# Then uncomment and replace <HASH> below:" >> "$GRUB_CONFIG"
        echo "#set superusers=\"root\"" >> "$GRUB_CONFIG"
        echo "#password_pbkdf2 root grub.pbkdf2.sha512.10000.<HASH>" >> "$GRUB_CONFIG"
        echo "# After editing, run: sudo update-grub" >> "$GRUB_CONFIG"
        echo "Template added to $GRUB_CONFIG"
    fi
fi

echo "=========================================="
echo "MANUAL ACTION REQUIRED"
echo "=========================================="
echo "This rule CANNOT be automatically remediated."
echo "Follow the steps above to complete GRUB password setup."
echo "After configuration, verify with:"
echo "  $ sudo grep password_pbkdf2 /boot/grub/grub.cfg"
echo ""

# This is a partial remediation - requires manual intervention
exit 1
