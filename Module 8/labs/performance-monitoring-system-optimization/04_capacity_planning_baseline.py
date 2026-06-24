"""
Capacity planning and scalability assessment.

This script creates a simple baseline and 12-month growth projection. Students
can replace the fallback baseline values with real DMV or Query Store metrics.
"""

from __future__ import annotations

import json
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
THRESHOLDS_PATH = LAB_DIR / "config" / "monitoring_thresholds.json"


def load_thresholds() -> dict:
    return json.loads(THRESHOLDS_PATH.read_text(encoding="utf-8"))


def build_projection(
    current_rows: int,
    current_storage_mb: float,
    monthly_growth_rate: float,
    planning_months: int,
) -> list[dict[str, float]]:
    projection = []
    rows = float(current_rows)
    storage_mb = float(current_storage_mb)
    for month_number in range(1, planning_months + 1):
        rows *= 1 + monthly_growth_rate
        storage_mb *= 1 + monthly_growth_rate
        projection.append(
            {
                "month_number": month_number,
                "projected_rows": int(round(rows)),
                "projected_storage_mb": round(storage_mb, 2),
            }
        )
    return projection


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    thresholds = load_thresholds()

    # Fallback baseline values for classroom practice.
    baseline = {
        "current_rows": 500_000,
        "current_storage_mb": 750.0,
        "avg_query_duration_ms": 420.0,
        "python_workflow_duration_seconds": 3.2,
        "python_peak_memory_mb": 82.0,
    }

    capacity_config = thresholds["capacity"]
    projection = build_projection(
        current_rows=baseline["current_rows"],
        current_storage_mb=baseline["current_storage_mb"],
        monthly_growth_rate=capacity_config["monthly_growth_rate"],
        planning_months=capacity_config["planning_months"],
    )

    result = {
        "baseline": baseline,
        "monthly_growth_rate": capacity_config["monthly_growth_rate"],
        "projection": projection,
        "interpretation": "Use the projection to decide when storage, indexing, or job runtime will need review.",
    }

    (OUTPUT_DIR / "capacity_projection.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
