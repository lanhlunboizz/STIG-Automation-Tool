#!/bin/bash
# Check if OpenSSH packages are installed

# Check for openssh-client, openssh-server, and openssh-sftp-server
if dpkg -l | grep -q "^ii.*openssh-client" && \
   dpkg -l | grep -q "^ii.*openssh-server" && \
   dpkg -l | grep -q "^ii.*openssh-sftp-server"; then
    echo "PASS: openssh packages (client, server, sftp-server) are installed"
    exit 0
else
    echo "FAIL: One or more openssh packages are NOT installed"
    echo "Required: openssh-client, openssh-server, openssh-sftp-server"
    exit 1
fi
