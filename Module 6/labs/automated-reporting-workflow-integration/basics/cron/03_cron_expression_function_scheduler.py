"""
Lesson 3: Cron-style expression check inside Python.

Linux cron uses five fields:
    minute hour day month day_of_week

Example:
    * * * * *      every minute
    30 7 1 * *     07:30 on the first day of every month

This example supports only "*" and exact numbers so the cron matching logic is
easy to inspect before using a full scheduler library.
"""

from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path


LESSON_DIR = Path(__file__).resolve().parent
OUTPUT_FILE = LESSON_DIR / "outputs" / "03_cron_expression_function_log.txt"


def cron_field_matches(field: str, value: int) -> bool:
    """Return True when one cron field matches the current date/time value."""
    if field == "*":
        return True
    return field.isdigit() and int(field) == value


def cron_matches(expression: str, now: datetime) -> bool:
    """Check a simple five-field cron expression against a datetime."""
    minute, hour, day, month, day_of_week = expression.split()

    # Python Monday is 0. Cron commonly uses Monday as 1 and Sunday as 0 or 7.
    cron_day_of_week = (now.weekday() + 1) % 7

    return (
        cron_field_matches(minute, now.minute)
        and cron_field_matches(hour, now.hour)
        and cron_field_matches(day, now.day)
        and cron_field_matches(month, now.month)
        and cron_field_matches(day_of_week, cron_day_of_week)
    )


def scheduled_function(reason: str) -> None:
    """This is the function that a cron-like condition triggers."""
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().isoformat(timespec="seconds")
    with OUTPUT_FILE.open("a", encoding="utf-8") as file:
        file.write(f"{timestamp} - cron expression function ran: {reason}\n")
    print(f"Cron expression function ran at {timestamp}: {reason}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Check a simple cron expression and run a function.")
    parser.add_argument("--cron", default="* * * * *", help="Five-field cron expression.")
    parser.add_argument("--force-run", action="store_true", help="Run the function immediately.")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    now = datetime.now()
    if args.force_run:
        scheduled_function("forced practice run")
    elif cron_matches(args.cron, now):
        scheduled_function(f"matched cron expression {args.cron}")
    else:
        print(f"No run. Current time does not match cron expression: {args.cron}")
