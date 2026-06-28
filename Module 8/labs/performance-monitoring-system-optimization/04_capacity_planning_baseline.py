"""
Capacity planning and scalability assessment.

This script creates a simple baseline and 12-month growth projection. Students
can replace the fallback baseline values with real DMV or Query Store metrics.
"""

from __future__ import annotations

import json
from pathlib import Path

from monitoring_data_sources import MODULE6_OUTPUTS, MODULE7_OUTPUTS, workflow_totals


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


def folder_size_mb(path: Path) -> float:
    """Measure current output storage for simple capacity planning."""
    if not path.exists():
        return 0.0
    total_bytes = sum(file.stat().st_size for file in path.rglob("*") if file.is_file())
    return round(total_bytes / 1024 / 1024, 4)


def build_baseline_from_prior_modules() -> dict[str, float | int | str]:
    """
    Build a baseline from actual Module 6/7 artifacts.

    A baseline is the starting measurement used for future comparison.
    """
    totals = workflow_totals()
    output_storage_mb = folder_size_mb(MODULE6_OUTPUTS) + folder_size_mb(MODULE7_OUTPUTS)

    return {
        "source": "Module 6 WEO reporting outputs and Module 7 IMF/BIS integration outputs",
        "workflow_count": totals["workflow_count"],
        "current_rows": max(int(totals["total_records_processed"]), 1),
        "current_storage_mb": round(max(output_storage_mb, 0.01), 4),
        "avg_workflow_duration_seconds": round(
            totals["total_duration_seconds"] / max(totals["workflow_count"], 1),
            4,
        ),
        "quality_issue_count": totals["total_quality_issues"],
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    thresholds = load_thresholds()

    baseline = build_baseline_from_prior_modules()

    capacity_config = thresholds["capacity"]
    projection = build_projection(
        current_rows=int(baseline["current_rows"]),
        current_storage_mb=float(baseline["current_storage_mb"]),
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
