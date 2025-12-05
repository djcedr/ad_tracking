#!/usr/bin/env python3
import os
import glob
import mimetypes
from datetime import date, timedelta
from collections import defaultdict
import requests
import matplotlib.pyplot as plt
from datetime import datetime

BASE_URL = os.environ.get("ADJUST_BASE_URL", "https://automate.adjust.com").rstrip("/")
REPORT_URL = f"{BASE_URL}/reports-service/report"
TOKEN = os.environ["ADJUST_TOKEN"]
SLACK_TOKEN = os.environ["SLACK_TOKEN"]
SLACK_CHANNEL = os.environ.get("SLACK_CHANNEL", "C0A02F1CBSB")
DAYS = int(os.environ.get("DAYS", "7"))


def _require_token() -> str:
    return TOKEN


def _date_period(last_n_days_inclusive: int) -> str:
    end = date.today() - timedelta(days=1)
    start = end - timedelta(days=last_n_days_inclusive - 1)
    return f"{start.isoformat()}:{end.isoformat()}"


def _fetch_report(params: dict) -> dict:
    r = requests.get(
        REPORT_URL,
        headers={"Authorization": f"Bearer {_require_token()}"},
        params=params,
        timeout=60,
    )
    if r.status_code == 204:
        return {"rows": []}
    r.raise_for_status()
    return r.json()


def _to_int(x) -> int:
    return int(float(x))


def _to_float(x) -> float:
    return float(x)


def _upload_slack_file(filepath: str, comment: str = "", channel: str = SLACK_CHANNEL) -> None:
    filename = os.path.basename(filepath)
    content_type = mimetypes.guess_type(filename)[0] or "application/octet-stream"
    file_size = os.path.getsize(filepath)
    
    response = requests.post(
        "https://slack.com/api/files.getUploadURLExternal",
        headers={
            "Authorization": f"Bearer {SLACK_TOKEN}",
        },
        data={
            "filename": filename,
            "length": str(file_size),
        },
        timeout=30,
    )
    response.raise_for_status()
    result = response.json()
    if not result.get("ok"):
        raise RuntimeError(f"Slack API error getting upload URL: {result.get('error', 'Unknown error')} (resp: {result})")
    print(f"Slack getUploadURLExternal ok: {result}")
    
    upload_url = result["upload_url"]
    file_id = result["file_id"]
    
    print(f"Uploading {filename} ({file_size} bytes) with Content-Type {content_type}")
    with open(filepath, 'rb') as f:
        upload_response = requests.post(
            upload_url,
            files={'file': (filename, f, content_type)},
            timeout=60,
        )
    upload_response.raise_for_status()
    
    complete_response = requests.post(
        "https://slack.com/api/files.completeUploadExternal",
        headers={"Authorization": f"Bearer {SLACK_TOKEN}"},
        json={
            "files": [{"id": file_id, "title": filename}],
            "channel_id": channel,
            "initial_comment": comment or filename,
        },
        timeout=30,
    )
    complete_response.raise_for_status()
    complete_result = complete_response.json()
    if not complete_result.get("ok"):
        raise RuntimeError(f"Slack API error completing upload: {complete_result.get('error', 'Unknown error')} (resp: {complete_result})")
    print(f"Slack completeUploadExternal ok: {complete_result}")


def generate_daily_graphs(days: int = DAYS) -> None:
    period = _date_period(days)
    today_str = date.today().isoformat()

    daily = _fetch_report({
        "date_period": period,
        "dimensions": "day",
        "metrics": "installs,cost,ecpi_all",
    }).get("rows", [])
    daily_by_day = {r.get("day"): r for r in daily if r.get("day") and r.get("day") != today_str}
    days_sorted = sorted(daily_by_day.keys())

    net_rows = _fetch_report({
        "date_period": period,
        "dimensions": "day,partner_name",
        "metrics": "network_cost",
        "ad_spend_mode": "network",
    }).get("rows", [])

    net_cost_by_day = defaultdict(dict)
    networks = set()
    for r in net_rows:
        d = r.get("day")
        if not d or d == today_str:
            continue
        n = (r.get("partner_name") or "").strip() or "(unknown)"
        c = _to_float(r.get("network_cost", 0) or 0.0)
        networks.add(n)
        net_cost_by_day[d][n] = net_cost_by_day[d].get(n, 0.0) + c

    networks = sorted(networks)

    dates = [datetime.strptime(d, "%Y-%m-%d") for d in days_sorted]

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    spend_filename = f"spend_by_channel_{timestamp}.png"
    ecpi_filename = f"installs_spend_ecpi_{timestamp}.png"

    plt.figure(figsize=(12, 6), facecolor="white")
    plt.gca().set_facecolor("white")
    for network in networks:
        spend_values = [net_cost_by_day.get(d, {}).get(network, 0.0) for d in days_sorted]
        plt.plot(dates, spend_values, marker='o', label=network, linewidth=2)
    
    plt.title("Spend by Channel", fontsize=14, fontweight='bold')
    plt.xlabel("Date", fontsize=12)
    plt.ylabel("Spend ($)", fontsize=12)
    plt.legend(loc='best', frameon=True)
    plt.grid(True, alpha=0.3)
    plt.gcf().autofmt_xdate()
    plt.tight_layout()
    plt.savefig(spend_filename, dpi=150, bbox_inches='tight', facecolor="white")
    print(f"Saved: {spend_filename}")
    plt.close()

    fig, ax1 = plt.subplots(figsize=(12, 6))
    fig.patch.set_facecolor("white")
    ax1.set_facecolor("white")
    
    installs_values = [_to_int(daily_by_day.get(d, {}).get("installs", 0) or 0) for d in days_sorted]
    spend_values = [_to_float(daily_by_day.get(d, {}).get("cost", 0) or 0.0) for d in days_sorted]
    ecpi_values = [_to_float(daily_by_day.get(d, {}).get("ecpi_all", 0) or 0.0) for d in days_sorted]

    ax1.set_xlabel("Date", fontsize=12)
    ax1.set_ylabel("Installs / Spend ($)", fontsize=12, color='tab:blue')
    line1 = ax1.plot(dates, installs_values, marker='o', label='Installs', color='tab:blue', linewidth=2)
    line2 = ax1.plot(dates, spend_values, marker='s', label='Spend ($)', color='tab:green', linewidth=2)
    ax1.tick_params(axis='y', labelcolor='tab:blue')
    ax1.grid(True, alpha=0.3)

    ax2 = ax1.twinx()
    ax2.set_ylabel("eCPI ($)", fontsize=12, color='tab:red')
    line3 = ax2.plot(dates, ecpi_values, marker='^', label='eCPI ($)', color='tab:red', linewidth=2)
    ax2.tick_params(axis='y', labelcolor='tab:red')

    lines = line1 + line2 + line3
    labels = [l.get_label() for l in lines]
    ax1.legend(lines, labels, loc='best', frameon=True)

    plt.title("Installs, Spend & eCPI (Global)", fontsize=14, fontweight='bold')
    fig.autofmt_xdate()
    plt.tight_layout()
    plt.savefig(ecpi_filename, dpi=150, bbox_inches='tight', facecolor="white")
    print(f"Saved: {ecpi_filename}")
    plt.close()

    end_date = date.today() - timedelta(days=1)
    end_date_str = end_date.strftime("%b. %d")
    
    _upload_slack_file(spend_filename, f"*[Paid ads]*: spend by channel up to {end_date_str}")
    _upload_slack_file(ecpi_filename, f"*[Paid ads]*: daily report up to {end_date_str}")


if __name__ == "__main__":
    png_files = glob.glob("*.png")
    for png_file in png_files:
        os.remove(png_file)
        print(f"Deleted: {png_file}")
    
    generate_daily_graphs()
