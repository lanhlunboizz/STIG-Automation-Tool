#!/bin/bash
# Check: Firewall enabled
# Rule: UBTU-24-010009

# Check UFW
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(ufw status | grep -i "Status:" | awk '{print $2}')
    if [ "$UFW_STATUS" = "active" ]; then
        echo "PASS: UFW firewall is active"
        exit 0
    fi
fi

# Check iptables
if command -v iptables &> /dev/null; then
    RULES=$(iptables -L | wc -l)
    if [ "$RULES" -gt 8 ]; then
        echo "PASS: iptables firewall is configured"
        exit 0
    fi
fi

echo "FAIL: No active firewall found"
exit 1
