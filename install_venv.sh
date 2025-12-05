#!/bin/bash
# Install matplotlib in venv when system matplotlib is available

set -e

echo "Installing matplotlib in virtual environment..."
echo ""

# Check if we're in a venv
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: Virtual environment not activated!"
    echo "Please run: source venv/bin/activate"
    exit 1
fi

echo "Virtual environment: $VIRTUAL_ENV"
echo ""

# Method 1: Try installing from system package location
if [ -d "/usr/lib/python3/dist-packages" ]; then
    echo "Attempting to link system matplotlib..."
    # Create a .pth file to include system site-packages
    SITE_PACKAGES=$(python -c "import site; print(site.getsitepackages()[0])")
    SYSTEM_PACKAGES="/usr/lib/python3/dist-packages"
    
    if [ -d "$SYSTEM_PACKAGES" ] && [ -f "$SYSTEM_PACKAGES/matplotlib/__init__.py" ]; then
        echo "$SYSTEM_PACKAGES" > "$SITE_PACKAGES/system_packages.pth"
        echo "Created .pth file to include system packages"
        python -c "import matplotlib; print(f'Matplotlib {matplotlib.__version__} found!')" && {
            echo "Success! System matplotlib is now accessible in venv."
            exit 0
        }
    fi
fi

# Method 2: Try installing with --no-build-isolation (often works better)
echo "Attempting to install matplotlib with reduced optimization..."
export CFLAGS="-O2"
export CXXFLAGS="-O2"

if pip install --no-build-isolation matplotlib>=3.7.0,<4.0.0; then
    echo "Success!"
    exit 0
fi

# Method 3: Try older version
echo "Trying matplotlib 3.7.0..."
pip install matplotlib==3.7.0 || {
    echo ""
    echo "=========================================="
    echo "Installation failed"
    echo "=========================================="
    echo ""
    echo "Since system matplotlib works, recreate venv with system packages:"
    echo ""
    echo "  deactivate"
    echo "  rm -rf venv"
    echo "  python3 -m venv --system-site-packages venv"
    echo "  source venv/bin/activate"
    echo "  pip install requests python-dotenv"
    echo ""
    exit 1
}

echo "Success!"


