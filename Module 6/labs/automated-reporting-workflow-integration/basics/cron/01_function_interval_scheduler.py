"""
Lesson 1: Run a function every few seconds.

This is a simple "cron inside application code" pattern:
- define a normal Python function
- register it with the scheduler
- keep the application running so the scheduler can call the function
"""

from __future__ import annotations

import argparse
import time
from datetime import datetime
from pathlib import Path

import schedule


LESSON_DIR = Path(__file__).resolve().parent
OUTPUT_FILE = LESSON_DIR / "outputs" / "01_interval_function_log.txt"


def write_heartbeat() -> None:
    """This is the function that gets triggered by the scheduler."""
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().isoformat(timespec="seconds")
    with OUTPUT_FILE.open("a", encoding="utf-8") as file:
        file.write(f"{timestamp} - interval function ran\n")
    print(f"Function ran at {timestamp}")


def run_scheduler(seconds: int, max_runs: int) -> None:
    schedule.clear()
    schedule.every(seconds).seconds.do(write_heartbeat)

    print(f"Scheduler started. Function will run every {seconds} seconds.")
    runs = 0
    while runs < max_runs:
        schedule.run_pending()
        time.sleep(1)
        runs = OUTPUT_FILE.read_text(encoding="utf-8").count("interval function ran") if OUTPUT_FILE.exists() else 0

    print(f"Stopped after {runs} function runs. Log: {OUTPUT_FILE}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run a function every few seconds.")
    parser.add_argument("--seconds", type=int, default=2)
    parser.add_argument("--max-runs", type=int, default=3)
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_scheduler(args.seconds, args.max_runs)
