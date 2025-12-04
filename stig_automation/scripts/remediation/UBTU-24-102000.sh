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
echo "IMPORTANT: You need to set a GRUB password"
echo "=========================================="
echo ""
echo "This remediation requires manual intervention:"
echo "1. Run: sudo grub-mkpasswd-pbkdf2"
echo "2. Enter your desired GRUB password twice"
echo "3. Copy the generated PBKDF2 hash"
echo "4. Add to $GRUB_CONFIG:"
echo "   set superusers=\"root\""
echo "   password_pbkdf2 root <your-pbkdf2-hash>"
echo "5. Run: sudo update-grub"
echo ""
echo "Example:"
echo "  set superusers=\"root\""
echo "  password_pbkdf2 root grub.pbkdf2.sha512.10000.HASH..."
echo ""

# Create a template in 40_custom if not exists
if [ -f "$GRUB_CONFIG" ]; then
    if ! grep -q "set superusers" "$GRUB_CONFIG"; then
        echo "" >> "$GRUB_CONFIG"
        echo "# STIG UBTU-24-102000: GRUB password authentication" >> "$GRUB_CONFIG"
        echo "# Uncomment and set password after generating with grub-mkpasswd-pbkdf2" >> "$GRUB_CONFIG"
        echo "#set superusers=\"root\"" >> "$GRUB_CONFIG"
        echo "#password_pbkdf2 root <INSERT-PBKDF2-HASH-HERE>" >> "$GRUB_CONFIG"
        echo "Template added to $GRUB_CONFIG"
    fi
fi

echo "MANUAL ACTION REQUIRED: Follow the steps above to complete GRUB password setup"
echo "After completing the steps, run update-grub and reboot to test"

# This is a partial remediation - requires manual intervention
exit 1
