"""
Python profiling and memory demo.

Run:
    python3 03_python_profiling_memory_demo.py

Learning focus:
- cProfile shows where the script spends time.
- tracemalloc shows peak memory use.
"""

from __future__ import annotations

import cProfile
import io
import json
import pstats
import time
import tracemalloc
from pathlib import Path


OUTPUT_DIR = Path(__file__).resolve().parent / "outputs"


def extract_data() -> list[int]:
    """Create small training data for the demo."""
    return list(range(50_000))


def slow_transform(rows: list[int]) -> int:
    """Beginner example of unnecessary intermediate list storage."""
    doubled_rows = []
    for row in rows:
        doubled_rows.append(row * 2)
    return sum(doubled_rows)


def fast_transform(rows: list[int]) -> int:
    """Generator expressions avoid storing the extra list."""
    return sum(row * 2 for row in rows)


def profile_step(step_name: str, function, rows: list[int]) -> dict[str, object]:
    """Run one function through cProfile and return a short summary."""
    profiler = cProfile.Profile()

    start = time.perf_counter()
    profiler.enable()
    result = function(rows)
    profiler.disable()
    duration_seconds = time.perf_counter() - start

    stream = io.StringIO()
    stats = pstats.Stats(profiler, stream=stream)
    stats.sort_stats("cumtime")
    stats.print_stats(10)

    return {
        "step_name": step_name,
        "function": function.__name__,
        "result": result,
        "duration_seconds": round(duration_seconds, 6),
        "profile_summary": stream.getvalue(),
    }


def trace_memory(step_name: str, function, rows: list[int]) -> dict[str, object]:
    """Run one function through tracemalloc and return memory use."""
    tracemalloc.start()
    function(rows)
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()

    return {
        "step_name": step_name,
        "function": function.__name__,
        "current_memory_mb": round(current / 1024 / 1024, 2),
        "peak_memory_mb": round(peak / 1024 / 1024, 2),
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)

    rows = extract_data()

    profile_results = [
        profile_step("Slow transform", slow_transform, rows),
        profile_step("Fast transform", fast_transform, rows),
    ]
    memory_results = [
        trace_memory("Slow transform", slow_transform, rows),
        trace_memory("Fast transform", fast_transform, rows),
    ]

    summary = {
        "lesson": "Profile first, then optimize the slow or memory-heavy step.",
        "slow_pattern": "Builds an unnecessary list before summing.",
        "better_pattern": "Uses a generator expression and avoids the extra list.",
    }

    (OUTPUT_DIR / "profile_summary.json").write_text(json.dumps(profile_results, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "memory_summary.json").write_text(json.dumps(memory_results, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "optimization_beginner_summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "profile_source_summary.json").write_text(
        json.dumps({"row_count_used_for_demo": len(rows), "source": "In-script training list"}, indent=2),
        encoding="utf-8",
    )

    print("Profile results")
    print(json.dumps(profile_results, indent=2))
    print("Memory results")
    print(json.dumps(memory_results, indent=2))


if __name__ == "__main__":
    main()
