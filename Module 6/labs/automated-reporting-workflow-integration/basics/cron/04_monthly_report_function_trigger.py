"""
Lesson 4: Put the Module 6 monthly report email trigger inside a function.

This shows the same pattern used by in-code schedulers:
1. Define the business function.
2. Schedule that function.
3. Keep the Python process alive.

Use --demo-once with the default dry-run behavior to create an email preview
instead of sending SMTP email.
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

import schedule


LAB_DIR = Path(__file__).resolve().parents[1]
EMAIL_TRIGGER = LAB_DIR / "07_send_monthly_report_email_trigger.py"


def scheduled_monthly_report_email(report_month: str, dry_run: bool = True) -> None:
    """Business function: create the report pack and email/preview it."""
    command = [
        sys.executable,
        str(EMAIL_TRIGGER),
        "--report-month",
        report_month,
    ]
    if dry_run:
        command.append("--dry-run")

    print(f"[{datetime.now().isoformat(timespec='seconds')}] Running monthly report function")
    completed = subprocess.run(command, cwd=LAB_DIR, text=True, capture_output=True, check=False)
    print(completed.stdout)
    if completed.returncode != 0:
        print(completed.stderr)
        raise RuntimeError(f"Monthly report function failed with exit code {completed.returncode}")


def run_daily_scheduler(report_month: str, run_at: str, dry_run: bool) -> None:
    schedule.clear()
    schedule.every().day.at(run_at).do(scheduled_monthly_report_email, report_month=report_month, dry_run=dry_run)

    print(f"In-code scheduler started. Monthly report function is scheduled at {run_at}.")
    print("Press Ctrl+C to stop.")
    while True:
        schedule.run_pending()
        time.sleep(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Schedule the Module 6 monthly report email function in Python.")
    parser.add_argument("--report-month", default="2026-06")
    parser.add_argument("--run-at", default="07:30", help="Daily time in HH:MM format for loop mode.")
    parser.add_argument("--demo-once", action="store_true", help="Run the function once and exit.")
    parser.add_argument("--run-loop", action="store_true", help="Keep the in-code scheduler running.")
    parser.add_argument("--send-email", action="store_true", help="Send SMTP email instead of creating a dry-run preview.")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    dry_run = not args.send_email
    if args.demo_once:
        scheduled_monthly_report_email(args.report_month, dry_run=dry_run)
    elif args.run_loop:
        run_daily_scheduler(args.report_month, args.run_at, dry_run=dry_run)
    else:
        print("Use --demo-once for a one-time practice run or --run-loop to keep the scheduler alive.")
