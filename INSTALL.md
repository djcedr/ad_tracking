# Installation Guide for Raspberry Pi

## Quick Install

```bash
pip install -r requirements.txt
```

**Note:** On Raspberry Pi, matplotlib installation can take 10-30+ minutes as some dependencies need to be compiled. This is normal - be patient!

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

### Still Having Issues?
Try installing matplotlib separately first:
```bash
pip install matplotlib --no-build-isolation
pip install -r requirements.txt
```

