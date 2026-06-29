"""
Module 6 scheduler demonstration.

This file does not replace Windows Task Scheduler or cron. It shows how a
Python scheduling library can keep a process alive and trigger workflow logic.

Use this for single test:

    python 05_scheduler_demo.py --demo-once

Use this to run a simple every-minute scheduler for testing:

    python 05_scheduler_demo.py --run-loop
"""

from __future__ import annotations

import argparse
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

import schedule


LAB_DIR = Path(__file__).resolve().parent
PIPELINE = LAB_DIR / "06_monthly_reporting_pipeline.py"


def run_monthly_report(report_month: str) -> None:
    """Run the monthly report as a subprocess so failures are visible."""
    print(f"[{datetime.now().isoformat(timespec='seconds')}] Starting scheduled report for {report_month}")
    command = [
        sys.executable,
        str(PIPELINE),
        "--report-month",
        report_month,
        "--refresh-data",
        "--dry-run-email",
    ]
    completed = subprocess.run(command, cwd=LAB_DIR, text=True, capture_output=True, check=False)
    print(completed.stdout)
    if completed.returncode != 0:
        print(completed.stderr)
        raise RuntimeError(f"Scheduled report failed with exit code {completed.returncode}")
    print(f"[{datetime.now().isoformat(timespec='seconds')}] Scheduled report completed")


def run_loop(report_month: str) -> None:
    """
    Classroom demo loop.

    Production systems should use Windows Task Scheduler, cron, or a managed
    scheduler unless there is a specific reason to keep a Python process alive.
    """
    schedule.every(1).minutes.do(run_monthly_report, report_month=report_month)
    print("Scheduler loop started. Press Ctrl+C to stop.")
    print("Demo schedule: run once every minute.")
    while True:
        schedule.run_pending()
        time.sleep(1)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Demonstrate Python scheduling for Module 6.")
    parser.add_argument("--report-month", default="2026-06")
    parser.add_argument("--demo-once", action="store_true", help="Run the scheduled action once and exit.")
    parser.add_argument("--run-loop", action="store_true", help="Run a every-minute scheduler loop.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.demo_once:
        run_monthly_report(args.report_month)
    elif args.run_loop:
        run_loop(args.report_month)
    else:
        print("No action selected. Use --demo-once for practice or --run-loop for scheduler demo.")


if __name__ == "__main__":
    main()
