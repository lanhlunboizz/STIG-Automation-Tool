#!/bin/bash
# Check if AppArmor is configured and enabled

if command -v aa-enabled &>/dev/null; then
    if aa-enabled &>/dev/null; then
        echo "PASS: AppArmor is configured and enabled"
        exit 0
    else
        echo "FAIL: AppArmor is NOT enabled"
        exit 1
    fi
else
    echo "FAIL: aa-enabled command not found"
    exit 1
fi
