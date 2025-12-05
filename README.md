# Ad Tracking Script

A Python script to fetch ad tracking data from Adjust API and generate daily reports with graphs, then upload them to Slack.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Create a `.env` file with your credentials:
```bash
cp .env.example .env
# Then edit .env with your actual tokens
```

The `.env` file is already created locally - just edit it with your actual tokens.

Or set environment variables manually:
```bash
export ADJUST_TOKEN="your_adjust_token_here"
export SLACK_TOKEN="your_slack_token_here"
export SLACK_CHANNEL="C0A02F1CBSB"  # Optional, defaults to C0A02F1CBSB
export DAYS=7  # Optional, defaults to 7
export ADJUST_BASE_URL="https://automate.adjust.com"  # Optional
```

3. Run the script manually:
```bash
python test.py
# Or use the convenience script:
./run.sh
```

## Automated Daily Execution (Raspberry Pi)

To run the script automatically every day at 7:00 AM on your Raspberry Pi:

1. **Clone or copy the repository to your Raspberry Pi:**
```bash
git clone https://github.com/djcedr/ad_tracking.git
cd ad_tracking
```

2. **Set up the environment:**
```bash
pip3 install -r requirements.txt
cp .env.example .env
# Edit .env with your actual tokens
nano .env
```

3. **Set up the cron job:**
```bash
./setup_cron.sh
```

This will automatically add a cron job that runs the script every day at 7:00 AM. Logs will be written to `cron.log` in the project directory.

**Manual cron management:**
- View cron jobs: `crontab -l`
- Edit cron jobs: `crontab -e`
- Remove the cron job: Delete the line containing `test.py` from your crontab

**Manual execution:**
You can always run the script manually using:
```bash
./run.sh
# or
python3 test.py
```

## Features

- Fetches daily ad performance data from Adjust API
- Generates two graphs:
  - Spend by Channel over time
  - Installs, Spend & eCPI (Global) over time
- Automatically uploads graphs to Slack
- Cleans up generated PNG files after upload

## Environment Variables

- `ADJUST_TOKEN` (required): Your Adjust API token
- `SLACK_TOKEN` (required): Your Slack API token
- `SLACK_CHANNEL` (optional): Slack channel ID (default: C0A02F1CBSB)
- `DAYS` (optional): Number of days to report (default: 7)
- `ADJUST_BASE_URL` (optional): Adjust API base URL (default: https://automate.adjust.com)

## Files

- `test.py` - Main script
- `run.sh` - Convenience script for manual execution
- `setup_cron.sh` - Script to set up daily cron job at 7 AM
- `.env` - Your local environment variables (not committed to git)
- `.env.example` - Template for environment variables
- `cron.log` - Log file created when running via cron

