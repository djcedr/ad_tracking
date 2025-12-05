#!/bin/bash
# Installation script for Raspberry Pi with workarounds for compilation issues

set -e

echo "Installing dependencies for Raspberry Pi..."
echo ""

# Try to install system dependencies first
echo "Step 1: Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y python3-dev python3-pip python3-venv \
    libfreetype6-dev libpng-dev libjpeg-dev \
    pkg-config build-essential || true

echo ""
echo "Step 2: Installing Python packages..."

# Method 1: Try installing matplotlib from system packages first (if available)
if python3 -c "import apt; cache = apt.Cache(); cache.open(); pkg = cache['python3-matplotlib']" 2>/dev/null; then
    echo "Attempting to install matplotlib from system packages..."
    sudo apt-get install -y python3-matplotlib || true
fi

# Method 2: Try installing with reduced optimization to avoid compiler crashes
export CFLAGS="-O2"
export CXXFLAGS="-O2"

# Method 3: Install packages one by one, with retries
echo "Installing requests..."
pip install requests>=2.31.0 || pip install requests

echo "Installing python-dotenv..."
pip install python-dotenv>=1.0.0 || pip install python-dotenv

echo "Installing matplotlib (this may take a while or fail)..."
# Try multiple approaches
if ! pip install matplotlib>=3.7.0,<4.0.0 2>&1 | tee /tmp/matplotlib_install.log; then
    echo ""
    echo "Matplotlib installation failed. Trying alternative approaches..."
    
    # Try older version that might have wheels
    echo "Trying matplotlib 3.7.0..."
    pip install matplotlib==3.7.0 || true
    
    # Try installing without build isolation
    echo "Trying without build isolation..."
    pip install --no-build-isolation matplotlib>=3.7.0,<4.0.0 || true
    
    # Try installing contourpy separately first with reduced optimization
    echo "Trying to install contourpy separately..."
    pip install --no-build-isolation "contourpy<1.2" || true
    
    # Final attempt with matplotlib
    echo "Final attempt with matplotlib..."
    pip install --no-build-isolation matplotlib>=3.7.0,<4.0.0 || {
        echo ""
        echo "=========================================="
        echo "INSTALLATION FAILED"
        echo "=========================================="
        echo ""
        echo "Matplotlib failed to install due to compiler issues."
        echo "Try one of these alternatives:"
        echo ""
        echo "Option 1: Install from system packages:"
        echo "  sudo apt-get install python3-matplotlib"
        echo ""
        echo "Option 2: Use a different Python version (Python 3.9 or 3.10)"
        echo ""
        echo "Option 3: Increase swap space and try again:"
        echo "  sudo dphys-swapfile swapoff"
        echo "  sudo nano /etc/dphys-swapfile  # Change CONF_SWAPSIZE to 2048"
        echo "  sudo dphys-swapfile setup"
        echo "  sudo dphys-swapfile swapon"
        echo ""
        exit 1
    }
fi

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "Testing matplotlib import..."
python3 -c "import matplotlib; print(f'Matplotlib {matplotlib.__version__} installed successfully!')" || {
    echo "Warning: Matplotlib import failed. You may need to install system packages."
}



