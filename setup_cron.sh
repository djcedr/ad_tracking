#!/bin/bash
# Setup script for running ad_tracking script daily at 7am

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_PATH="$(which python3)"
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

