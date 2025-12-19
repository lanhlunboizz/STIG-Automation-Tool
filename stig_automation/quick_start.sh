#!/bin/bash
# Quick start script

echo "================================================"
echo "STIG Automation Tool - Quick Start"
echo "================================================"
echo ""

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Install dependencies
echo ""
echo "Installing Python dependencies..."
sudo apt-get install -y python3-pip python3-venv
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt

# Set permissions
echo ""
echo "Setting script permissions..."
bash setup_permissions.sh
chmod +x run_with_sudo.sh

# Create directories
echo ""
echo "Creating directories..."
mkdir -p reports logs

echo ""
echo "================================================"
echo "✓ Setup completed successfully!"
echo "================================================"
echo ""
echo "Usage examples:"
echo ""
echo "  # Check locally (no remediation)"
echo "  ./run_with_sudo.sh --mode local --check-only"
echo ""
echo "  # Check and auto-fix locally (recommended)"
echo "  ./run_with_sudo.sh --mode local --auto-remediate"
echo ""
echo "  # Check via SSH"
echo "  python3 main.py --mode ssh --host 192.168.1.100 --user ubuntu --key ~/.ssh/id_rsa"
echo ""
echo "For more options: python3 main.py --help"
echo ""
