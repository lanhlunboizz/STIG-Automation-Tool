# Example: Run on local system with auto-remediation
sudo python3 main.py --mode local --auto-remediate

# Example: Check only without remediation
python3 main.py --mode local --check-only

# Example: SSH to remote system and check
python3 main.py --mode ssh \
    --host 192.168.1.100 \
    --user ubuntu \
    --key ~/.ssh/id_rsa \
    --check-only

# Example: SSH with auto-remediation
python3 main.py --mode ssh \
    --host 192.168.1.100 \
    --user ubuntu \
    --key ~/.ssh/id_rsa \
    --auto-remediate

# Example: Check specific rules only
python3 main.py --mode local \
    --rules UBTU-24-010001,UBTU-24-010002,UBTU-24-010003 \
    --check-only

# Example: With debug logging
python3 main.py --mode local \
    --auto-remediate \
    --log-level DEBUG

# Example: SSH with password
python3 main.py --mode ssh \
    --host 192.168.1.100 \
    --user ubuntu \
    --password yourpassword \
    --check-only
