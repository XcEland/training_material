"""
Python profiling and memory management demo.

Learning focus:
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

from monitoring_data_sources import build_workflow_observations


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"


def build_training_rows(row_count: int = 25_000) -> list[dict[str, float]]:
    """Create predictable fallback training data."""
    return [
        {
            "row_id": i,
            "amount": float((i % 500) + 1),
            "risk_weight": 1.0 + ((i % 7) * 0.05),
        }
        for i in range(row_count)
    ]


def build_rows_from_prior_modules(repeat_per_workflow: int = 12_000) -> list[dict[str, float]]:
    """
    Convert Module 6/7 monitoring observations into rows for profiling.

    We repeat each workflow observation so the profiler has enough work to
    measure. In production, these rows would already be large ETL result sets.
    """
    observations = build_workflow_observations()
    rows: list[dict[str, float]] = []

    for workflow_index, observation in enumerate(observations):
        records_processed = max(float(observation["records_processed"]), 1.0)
        duration_seconds = max(float(observation["duration_seconds"]), 0.01)
        for i in range(repeat_per_workflow):
            rows.append(
                {
                    "row_id": float((workflow_index * repeat_per_workflow) + i),
                    "amount": records_processed + float(i % 100),
                    "risk_weight": 1.0 + (duration_seconds / 100.0),
                }
            )

    return rows or build_training_rows()


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


def build_beginner_summary(profile_results: list[dict[str, object]], memory_results: list[dict[str, object]]) -> dict[str, object]:
    """Create a short interpretation of the profiling results."""
    inefficient_profile = next(item for item in profile_results if item["function"] == "inefficient_total")
    optimized_profile = next(item for item in profile_results if item["function"] == "optimized_total")
    inefficient_memory = next(item for item in memory_results if item["function"] == "inefficient_total")
    optimized_memory = next(item for item in memory_results if item["function"] == "optimized_total")

    duration_saved = float(inefficient_profile["duration_seconds"]) - float(optimized_profile["duration_seconds"])
    memory_saved = float(inefficient_memory["peak_memory_mb"]) - float(optimized_memory["peak_memory_mb"])

    return {
        "lesson": "Avoid building intermediate lists when a generator expression is enough.",
        "inefficient_function": inefficient_profile["function"],
        "optimized_function": optimized_profile["function"],
        "duration_seconds_saved": round(duration_saved, 6),
        "peak_memory_mb_saved": round(memory_saved, 4),
        "how_to_read_this": [
            "Open profile_summary.json to see which function consumed time.",
            "Open memory_summary.json to compare peak memory use.",
            "Open this file to explain the result in plain language.",
        ],
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    rows = build_rows_from_prior_modules()

    profile_results = [
        profile_function(inefficient_total, rows),
        profile_function(optimized_total, rows),
    ]
    memory_results = [
        trace_memory(inefficient_total, rows),
        trace_memory(optimized_total, rows),
    ]
    beginner_summary = build_beginner_summary(profile_results, memory_results)

    (OUTPUT_DIR / "profile_summary.json").write_text(json.dumps(profile_results, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "memory_summary.json").write_text(json.dumps(memory_results, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "optimization_beginner_summary.json").write_text(
        json.dumps(beginner_summary, indent=2),
        encoding="utf-8",
    )
    (OUTPUT_DIR / "profile_source_summary.json").write_text(
        json.dumps(
            {
                "source": "Module 6 and Module 7 monitoring outputs",
                "row_count_used_for_demo": len(rows),
                "note": "Rows are repeated from prior workflow observations so cProfile and tracemalloc have measurable work.",
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    print("Profile results:")
    print(json.dumps(profile_results, indent=2))
    print("Memory results:")
    print(json.dumps(memory_results, indent=2))
    print("Beginner summary:")
    print(json.dumps(beginner_summary, indent=2))


if __name__ == "__main__":
    main()
