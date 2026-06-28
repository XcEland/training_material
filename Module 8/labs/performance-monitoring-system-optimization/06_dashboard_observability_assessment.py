"""
Assess the Module 8 monitoring dashboard against observability standards.

Beginner idea:
Rendering a dashboard is not enough. Operations teams must also ask:
- Does it include the required database metrics?
- Does it include the required Python workflow metrics?
- Are alert levels present?
- Are quality gate and workflow status visible?

Run after `05_monitoring_dashboard.py`:
    python 06_dashboard_observability_assessment.py
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
SNAPSHOT_PATH = OUTPUT_DIR / "monitoring_snapshot.json"
ASSESSMENT_PATH = OUTPUT_DIR / "dashboard_observability_assessment.json"


def load_snapshot() -> dict[str, Any]:
    """Load the dashboard snapshot created by 05_monitoring_dashboard.py."""
    if not SNAPSHOT_PATH.exists():
        raise FileNotFoundError(
            "Run 05_monitoring_dashboard.py before running the dashboard assessment."
        )
    return json.loads(SNAPSHOT_PATH.read_text(encoding="utf-8"))


def count_alerts(metrics: list[dict[str, Any]]) -> dict[str, int]:
    """Count Normal, Warning, and Critical alert labels."""
    counts = {"Normal": 0, "Warning": 0, "Critical": 0}
    for metric in metrics:
        alert_level = metric.get("alert_level", "Unknown")
        if alert_level in counts:
            counts[alert_level] += 1
    return counts


def assess_snapshot(snapshot: dict[str, Any]) -> dict[str, Any]:
    """Return a pass/fail assessment for operational observability."""
    database_metrics = snapshot.get("database_metrics", [])
    python_metrics = snapshot.get("python_metrics", [])
    workflow_metrics = snapshot.get("workflow_metrics", [])
    workflow_observations = snapshot.get("workflow_observations", [])
    capacity_projection = snapshot.get("capacity_projection", [])

    all_metrics = database_metrics + python_metrics + workflow_metrics
    alert_counts = count_alerts(all_metrics)

    standards = [
        {
            "standard": "Database performance metrics are present",
            "passed": len(database_metrics) >= 3,
            "evidence": f"{len(database_metrics)} database metrics found.",
        },
        {
            "standard": "Python profiling and workflow metrics are present",
            "passed": len(python_metrics) >= 3,
            "evidence": f"{len(python_metrics)} Python metrics found.",
        },
        {
            "standard": "Module 6 and Module 7 workflow status is visible",
            "passed": len(workflow_observations) >= 2,
            "evidence": f"{len(workflow_observations)} workflow observations found.",
        },
        {
            "standard": "Quality gate status is visible",
            "passed": any(item.get("metric_name") == "Quality Issue Count" for item in workflow_metrics),
            "evidence": "Quality Issue Count panel checked.",
        },
        {
            "standard": "Capacity projection is present",
            "passed": len(capacity_projection) >= 12,
            "evidence": f"{len(capacity_projection)} projection rows found.",
        },
        {
            "standard": "Every metric has an alert level",
            "passed": all(item.get("alert_level") in ("Normal", "Warning", "Critical") for item in all_metrics),
            "evidence": f"Alert counts: {alert_counts}.",
        },
    ]

    passed_count = sum(1 for item in standards if item["passed"])
    return {
        "passed": passed_count == len(standards),
        "passed_count": passed_count,
        "total_count": len(standards),
        "alert_counts": alert_counts,
        "standards": standards,
        "recommendation": (
            "Ready for classroom submission."
            if passed_count == len(standards)
            else "Review failed standards before submission."
        ),
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    snapshot = load_snapshot()
    assessment = assess_snapshot(snapshot)
    ASSESSMENT_PATH.write_text(json.dumps(assessment, indent=2), encoding="utf-8")
    print(json.dumps(assessment, indent=2))


if __name__ == "__main__":
    main()
