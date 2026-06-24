"""
Python profiling and memory management demo.

Beginner idea:
Profiling answers "where is my script spending time?"
Memory tracing answers "where is my script using memory?"

This script compares a deliberately inefficient workflow with a more efficient
workflow, then writes profile and memory summaries to outputs/.
"""

from __future__ import annotations

import cProfile
import io
import json
import pstats
import time
import tracemalloc
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"


def build_training_rows(row_count: int = 25_000) -> list[dict[str, float]]:
    """Create predictable training data."""
    return [
        {
            "row_id": i,
            "amount": float((i % 500) + 1),
            "risk_weight": 1.0 + ((i % 7) * 0.05),
        }
        for i in range(row_count)
    ]


def inefficient_total(rows: list[dict[str, float]]) -> float:
    """
    Inefficient pattern:
    - repeated list growth
    - extra intermediate data
    - unnecessary loop work
    """
    weighted_values = []
    for row in rows:
        weighted_values.append(row["amount"] * row["risk_weight"])
    return sum(weighted_values)


def optimized_total(rows: list[dict[str, float]]) -> float:
    """
    Optimized pattern:
    - generator expression avoids building an intermediate list
    - less memory pressure
    """
    return sum(row["amount"] * row["risk_weight"] for row in rows)


def profile_function(function, rows: list[dict[str, float]]) -> dict[str, object]:
    profiler = cProfile.Profile()
    started = time.perf_counter()
    result = profiler.runcall(function, rows)
    duration_seconds = time.perf_counter() - started

    stream = io.StringIO()
    stats = pstats.Stats(profiler, stream=stream).sort_stats("cumtime")
    stats.print_stats(8)

    return {
        "function": function.__name__,
        "result": round(result, 2),
        "duration_seconds": round(duration_seconds, 6),
        "profile_summary": stream.getvalue(),
    }


def trace_memory(function, rows: list[dict[str, float]]) -> dict[str, object]:
    tracemalloc.start()
    function(rows)
    current, peak = tracemalloc.get_traced_memory()
    tracemalloc.stop()
    return {
        "function": function.__name__,
        "current_memory_mb": round(current / 1024 / 1024, 4),
        "peak_memory_mb": round(peak / 1024 / 1024, 4),
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    rows = build_training_rows()

    profile_results = [
        profile_function(inefficient_total, rows),
        profile_function(optimized_total, rows),
    ]
    memory_results = [
        trace_memory(inefficient_total, rows),
        trace_memory(optimized_total, rows),
    ]

    (OUTPUT_DIR / "profile_summary.json").write_text(json.dumps(profile_results, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "memory_summary.json").write_text(json.dumps(memory_results, indent=2), encoding="utf-8")

    print("Profile results:")
    print(json.dumps(profile_results, indent=2))
    print("Memory results:")
    print(json.dumps(memory_results, indent=2))


if __name__ == "__main__":
    main()
