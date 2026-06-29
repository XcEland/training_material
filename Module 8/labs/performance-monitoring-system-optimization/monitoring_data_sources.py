"""
Small data-loading helpers for Module 8 monitoring labs.

The monitoring examples use real artifacts created in earlier modules:
- Module 6 monthly WEO reporting outputs
- Module 7 external API integration outputs

If those files are missing, the helpers return safe classroom fallback values so
students can still run the labs in isolation.
"""

from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path
from typing import Any


LAB_DIR = Path(__file__).resolve().parent
REPO_ROOT = LAB_DIR.parents[2]
MODULE6_OUTPUTS = REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / "outputs"
MODULE7_OUTPUTS = REPO_ROOT / "Module 7" / "labs" / "api-integration-external-data-sources" / "outputs"


def read_json(path: Path, fallback: dict[str, Any] | None = None) -> dict[str, Any]:
    """Read one JSON file and return a dictionary."""
    if not path.exists():
        return fallback or {}
    return json.loads(path.read_text(encoding="utf-8"))


def read_jsonl(path: Path) -> list[dict[str, Any]]:
    """Read a JSON Lines file where each line is one JSON object."""
    if not path.exists():
        return []

    records: list[dict[str, Any]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip():
            records.append(json.loads(line))
    return records


def seconds_between(started_at: str | None, completed_at: str | None) -> float:
    """Convert ISO start/end timestamps into elapsed seconds."""
    if not started_at or not completed_at:
        return 0.0

    start = datetime.fromisoformat(started_at.replace("Z", "+00:00"))
    end = datetime.fromisoformat(completed_at.replace("Z", "+00:00"))
    return round((end - start).total_seconds(), 4)


def load_latest_module6_run() -> dict[str, Any]:
    """Load the latest Module 6 monthly reporting run log entry."""
    records = read_jsonl(MODULE6_OUTPUTS / "monthly_report_run_log.jsonl")
    if records:
        return records[-1]

    return {
        "report_month": "sample",
        "status": "Fallback",
        "generated_reports": [],
        "email_status": "NotAvailable",
        "started_at": None,
        "completed_at": None,
        "message": "Module 6 run log not found.",
    }


def load_module6_metrics() -> dict[str, Any]:
    """Load the richer Module 6 metrics file when available."""
    return read_json(
        MODULE6_OUTPUTS / "weo_monthly_metrics_2026-06.json",
        {
            "pipeline_seconds": 22.0,
            "reports": [],
            "recipient_count": 0,
            "email_status": "Fallback",
        },
    )


def load_module7_summary() -> dict[str, Any]:
    """Load the Module 7 external data integration run summary."""
    return read_json(
        MODULE7_OUTPUTS / "external_integration_run_summary.json",
        {
            "accepted_imf_rows": 24,
            "accepted_bis_policy_rate_rows": 6,
            "accepted_authorised_source_rows": 3,
            "quality_issue_rows": 0,
            "quality_gate_passed": True,
            "duration_seconds": 0.05,
            "sql_status": "Fallback",
        },
    )


def load_module7_quality_alert() -> dict[str, Any]:
    """Load the Module 7 quality gate alert output."""
    return read_json(
        MODULE7_OUTPUTS / "external_data_quality_alert.json",
        {
            "quality_gate_passed": True,
            "alert_required": False,
            "issue_count": 0,
            "issues": [],
        },
    )


def build_workflow_observations() -> list[dict[str, Any]]:
    """
    Convert previous module artifacts into a simple monitoring table.

    Each row represents one workflow that a Central Bank operations team may
    monitor after scheduled execution.
    """
    module6_run = load_latest_module6_run()
    module6_metrics = load_module6_metrics()
    module7_summary = load_module7_summary()
    module7_alert = load_module7_quality_alert()

    module6_duration = module6_metrics.get("pipeline_seconds") or seconds_between(
        module6_run.get("started_at"),
        module6_run.get("completed_at"),
    )
    module6_reports = module6_metrics.get("reports", [])
    module6_country_rows = sum(
        report.get("metrics", {}).get("country_rows", 0)
        for report in module6_reports
    )

    module7_accepted_rows = (
        int(module7_summary.get("accepted_imf_rows", 0))
        + int(module7_summary.get("accepted_bis_policy_rate_rows", 0))
        + int(module7_summary.get("accepted_authorised_source_rows", 0))
    )

    return [
        {
            "workflow_name": "Module 6 WEO monthly reporting",
            "source": "monthly_report_run_log.jsonl and weo_monthly_metrics_2026-06.json",
            "status": module6_run.get("status", "Unknown"),
            "duration_seconds": float(module6_duration or 0.0),
            "records_processed": int(module6_country_rows or 0),
            "outputs_created": len(module6_run.get("generated_reports", [])),
            "quality_issue_count": 0,
            "notification_status": module6_run.get("email_status", "Unknown"),
        },
        {
            "workflow_name": "Module 7 IMF/BIS external data integration",
            "source": "external_integration_run_summary.json and external_data_quality_alert.json",
            "status": "Succeeded" if module7_summary.get("quality_gate_passed") else "QualityGateFailed",
            "duration_seconds": float(module7_summary.get("duration_seconds", 0.0)),
            "records_processed": module7_accepted_rows,
            "outputs_created": 3,
            "quality_issue_count": int(module7_alert.get("issue_count", 0)),
            "notification_status": "AlertRequired" if module7_alert.get("alert_required") else "NoAlertRequired",
        },
    ]


def workflow_totals() -> dict[str, Any]:
    """Create simple totals used by the dashboard and capacity lab."""
    observations = build_workflow_observations()
    return {
        "workflow_count": len(observations),
        "total_records_processed": sum(row["records_processed"] for row in observations),
        "total_duration_seconds": round(sum(row["duration_seconds"] for row in observations), 4),
        "total_quality_issues": sum(row["quality_issue_count"] for row in observations),
        "observations": observations,
    }
