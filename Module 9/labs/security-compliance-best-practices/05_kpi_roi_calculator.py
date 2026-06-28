"""
Calculate simple KPIs and ROI for database/Python automation investment.

This is not a finance model. It is a beginner-friendly framework for showing
measurable value from automation, while still acknowledging security, audit, and
quality benefits.
"""

from __future__ import annotations

import json
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parent
REPO_ROOT = LAB_DIR.parents[2]
OUTPUT_DIR = LAB_DIR / "outputs"
MODULE6_OUTPUTS = REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / "outputs"
MODULE7_OUTPUTS = REPO_ROOT / "Module 7" / "labs" / "api-integration-external-data-sources" / "outputs"


def read_json(path: Path, fallback: dict) -> dict:
    if not path.exists():
        return fallback
    return json.loads(path.read_text(encoding="utf-8"))


def calculate_roi(
    hours_saved_per_month: float,
    average_hourly_cost: float,
    annual_operating_cost: float,
    implementation_cost: float,
) -> dict[str, float]:
    """Return a simple annual ROI calculation."""
    annual_benefit = hours_saved_per_month * 12 * average_hourly_cost
    annual_net_benefit = annual_benefit - annual_operating_cost
    roi_percentage = (annual_net_benefit / implementation_cost) * 100 if implementation_cost else 0.0

    return {
        "annual_benefit": round(annual_benefit, 2),
        "annual_net_benefit": round(annual_net_benefit, 2),
        "roi_percentage": round(roi_percentage, 2),
    }


def build_kpis() -> dict:
    """Build KPI examples using prior module outputs."""
    module6_metrics = read_json(
        MODULE6_OUTPUTS / "weo_monthly_metrics_2026-06.json",
        {"pipeline_seconds": 0, "reports": [], "email_status": "Unknown"},
    )
    module7_summary = read_json(
        MODULE7_OUTPUTS / "external_integration_run_summary.json",
        {"quality_gate_passed": False, "quality_issue_rows": 0, "duration_seconds": 0},
    )

    report_count = len(module6_metrics.get("reports", []))
    quality_gate_passed = bool(module7_summary.get("quality_gate_passed"))

    roi = calculate_roi(
        hours_saved_per_month=40,
        average_hourly_cost=35,
        annual_operating_cost=2000,
        implementation_cost=6000,
    )

    return {
        "kpis": {
            "reports_generated": report_count,
            "module6_pipeline_seconds": module6_metrics.get("pipeline_seconds", 0),
            "module6_email_status": module6_metrics.get("email_status", "Unknown"),
            "module7_quality_gate_passed": quality_gate_passed,
            "module7_quality_issue_rows": module7_summary.get("quality_issue_rows", 0),
            "module7_duration_seconds": module7_summary.get("duration_seconds", 0),
        },
        "roi_assumptions": {
            "hours_saved_per_month": 40,
            "average_hourly_cost": 35,
            "annual_operating_cost": 2000,
            "implementation_cost": 6000,
        },
        "roi": roi,
        "interpretation": "Use ROI together with security findings, audit readiness, and quality results.",
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    result = build_kpis()
    output_path = OUTPUT_DIR / "kpi_roi_summary.json"
    output_path.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
