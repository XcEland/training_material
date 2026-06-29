"""
Lesson 2: Run a function at a specific clock time.

For practice, the default scheduled time is a few seconds from now.
In a real application, you might use "07:30" for a daily reporting task.
"""

from __future__ import annotations

import argparse
import time
from datetime import datetime, timedelta
from pathlib import Path

import schedule


LESSON_DIR = Path(__file__).resolve().parent
OUTPUT_FILE = LESSON_DIR / "outputs" / "02_daily_time_function_log.txt"


def write_daily_marker() -> schedule.CancelJob:
    """This function is triggered at the selected clock time."""
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().isoformat(timespec="seconds")
    with OUTPUT_FILE.open("a", encoding="utf-8") as file:
        file.write(f"{timestamp} - daily time function ran\n")
    print(f"Daily time function ran at {timestamp}")

    # Stop this demo after one run. A production app would not return CancelJob.
    return schedule.CancelJob


def run_scheduler(run_at: str, max_wait_seconds: int) -> None:
    schedule.clear()
    schedule.every().day.at(run_at).do(write_daily_marker)

    print(f"Scheduler started. Waiting for daily time: {run_at}")
    stop_at = time.time() + max_wait_seconds
    while time.time() < stop_at:
        schedule.run_pending()
        time.sleep(1)

    print(f"Practice run finished. Log: {OUTPUT_FILE}")


def parse_args() -> argparse.Namespace:
    default_run_at = (datetime.now() + timedelta(seconds=5)).strftime("%H:%M:%S")
    parser = argparse.ArgumentParser(description="Run a function at a selected clock time.")
    parser.add_argument("--run-at", default=default_run_at, help="Time in HH:MM or HH:MM:SS format.")
    parser.add_argument("--max-wait-seconds", type=int, default=15)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_scheduler(args.run_at, args.max_wait_seconds)
