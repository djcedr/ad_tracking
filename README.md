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

3. Run the script:
```bash
python test.py
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

