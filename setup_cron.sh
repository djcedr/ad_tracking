#!/bin/bash
# Setup script for running ad_tracking script daily at 7am

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if venv exists and use its Python, otherwise use system Python
if [ -f "$SCRIPT_DIR/venv/bin/python3" ]; then
    PYTHON_PATH="$SCRIPT_DIR/venv/bin/python3"
    echo "Using virtual environment Python: $PYTHON_PATH"
elif [ -f "$SCRIPT_DIR/venv/bin/python" ]; then
    PYTHON_PATH="$SCRIPT_DIR/venv/bin/python"
    echo "Using virtual environment Python: $PYTHON_PATH"
else
    PYTHON_PATH="$(which python3)"
    echo "Using system Python: $PYTHON_PATH"
    echo "Note: Consider creating a virtual environment for better isolation"
fi

# Create cron job that uses venv Python and loads .env
# The .env file is loaded automatically by python-dotenv in the script
CRON_JOB="0 7 * * * cd $SCRIPT_DIR && $PYTHON_PATH test.py >> $SCRIPT_DIR/cron.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "test.py"; then
    echo "Cron job already exists. Removing old entry..."
    crontab -l 2>/dev/null | grep -v "test.py" | crontab -
fi

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
echo "Cron job added successfully!"
echo ""
echo "The script will run every day at 7:00 AM"
echo "Logs will be written to: $SCRIPT_DIR/cron.log"
echo ""
echo "To view your cron jobs: crontab -l"
echo "To remove this cron job: crontab -e (then delete the line)"

