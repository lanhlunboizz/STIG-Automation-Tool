#!/bin/bash
# Check: Password complexity requirements
# Rule: UBTU-24-010002

# Kiểm tra pwquality configuration
CONFIG_FILE="/etc/security/pwquality.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "FAIL: $CONFIG_FILE not found"
    exit 1
fi

# Check các yêu cầu
MINLEN=$(grep "^minlen" $CONFIG_FILE | awk '{print $3}')
DCREDIT=$(grep "^dcredit" $CONFIG_FILE | awk '{print $3}')
UCREDIT=$(grep "^ucredit" $CONFIG_FILE | awk '{print $3}')
LCREDIT=$(grep "^lcredit" $CONFIG_FILE | awk '{print $3}')
OCREDIT=$(grep "^ocredit" $CONFIG_FILE | awk '{print $3}')

FAIL=0

if [ -z "$MINLEN" ] || [ "$MINLEN" -lt 14 ]; then
    echo "FAIL: minlen not set or less than 14"
    FAIL=1
fi

if [ -z "$DCREDIT" ] || [ "$DCREDIT" -gt -1 ]; then
    echo "FAIL: dcredit not properly configured"
    FAIL=1
fi

if [ -z "$UCREDIT" ] || [ "$UCREDIT" -gt -1 ]; then
    echo "FAIL: ucredit not properly configured"
    FAIL=1
fi

if [ -z "$LCREDIT" ] || [ "$LCREDIT" -gt -1 ]; then
    echo "FAIL: lcredit not properly configured"
    FAIL=1
fi

if [ -z "$OCREDIT" ] || [ "$OCREDIT" -gt -1 ]; then
    echo "FAIL: ocredit not properly configured"
    FAIL=1
fi

if [ $FAIL -eq 0 ]; then
    echo "PASS: Password complexity requirements are configured"
    exit 0
else
    exit 1
fi
