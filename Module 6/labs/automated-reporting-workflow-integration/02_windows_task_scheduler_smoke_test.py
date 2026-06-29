"""
Beginner Windows Task Scheduler smoke test.

This script is intentionally small. When Windows Task Scheduler runs it, the
script appends one timestamp line to a text file. Learners can confirm that the
scheduled trigger worked before they schedule the full reporting pipeline.

Manual run:
    python 02_windows_task_scheduler_smoke_test.py

Optional custom output:
    python 02_windows_task_scheduler_smoke_test.py --output outputs/task_scheduler_smoke_test.txt
"""

from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parent
DEFAULT_OUTPUT = LAB_DIR / "outputs" / "task_scheduler_smoke_test.txt"


def append_run_log(output_path: Path) -> None:
    """Append one timestamp line to the selected text file."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().isoformat(timespec="seconds")
    with output_path.open("a", encoding="utf-8") as file:
        file.write(f"{timestamp} - The scheduled task script ran.\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Write one scheduled-task timestamp to a text file.")
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT),
        help="Text file that receives the timestamp line.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output_path = Path(args.output).expanduser()
    append_run_log(output_path)
    print(f"Wrote scheduled-task timestamp to: {output_path}")


if __name__ == "__main__":
    main()
