# Installation Guide for Raspberry Pi

## Quick Install (Recommended)

Use the automated installation script:
```bash
chmod +x install_pi.sh
./install_pi.sh
```

## Manual Install

```bash
pip install -r requirements.txt
```

**⚠️ Warning:** On Raspberry Pi, matplotlib installation often fails due to GCC compiler crashes when building `contourpy` from source. Use the `install_pi.sh` script instead!

## Faster Installation (Recommended)

If you want to speed things up, install system dependencies first:

```bash
# Install system dependencies for matplotlib
sudo apt-get update
sudo apt-get install -y python3-dev python3-pip python3-venv \
    libfreetype6-dev libpng-dev libjpeg-dev \
    pkg-config

# Then install Python packages
pip install -r requirements.txt
```

## Alternative: Use Pre-built Wheels Only

To avoid building from source (faster but may fail if wheels aren't available):

```bash
pip install --only-binary :all: -r requirements.txt
```

## Troubleshooting

### Installation Stuck at "Preparing metadata"
- This is normal on Raspberry Pi - it's compiling C extensions
- Can take 10-30+ minutes depending on your Pi model
- Just wait - don't interrupt it
- If it fails, try installing system dependencies first (see above)

### Out of Memory Errors
If you get memory errors during installation:
```bash
# Increase swap space temporarily
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile  # Change CONF_SWAPSIZE to 2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### Compiler Crashes (Segmentation Fault)
If you see "internal compiler error: Segmentation fault" when building contourpy:

**Best Solution:** Use the automated installer:
```bash
./install_pi.sh
```

**Alternative Solutions:**

1. **Install from system packages:**
```bash
sudo apt-get install python3-matplotlib
# Then install other packages
pip install requests python-dotenv
```

2. **Use Python 3.9 or 3.10** (better wheel support):
```bash
python3.9 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

3. **Increase swap space** (helps with memory issues):
```bash
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile  # Change CONF_SWAPSIZE to 2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

4. **Try older matplotlib version:**
```bash
pip install matplotlib==3.7.0
```

