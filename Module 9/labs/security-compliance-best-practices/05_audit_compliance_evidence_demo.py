"""
Build a simple audit and compliance evidence pack.

This demo uses outputs from Modules 6, 7, and 8 to show what audit evidence can
look like for Central Bank automation:
- who/what process ran
- what data was processed
- whether quality gates passed
- what reports or dashboards were produced
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


LAB_DIR = Path(__file__).resolve().parent
REPO_ROOT = LAB_DIR.parents[2]
OUTPUT_DIR = LAB_DIR / "outputs"

MODULE6_OUTPUTS = REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / "outputs"
MODULE7_OUTPUTS = REPO_ROOT / "Module 7" / "labs" / "api-integration-external-data-sources" / "outputs"
MODULE8_OUTPUTS = REPO_ROOT / "Module 8" / "labs" / "performance-monitoring-system-optimization" / "outputs"


def read_json(path: Path, fallback: dict[str, Any]) -> dict[str, Any]:
    if not path.exists():
        return fallback
    return json.loads(path.read_text(encoding="utf-8"))


def build_audit_events() -> list[dict[str, Any]]:
    """Create audit events from the course automation outputs."""
    module6_metrics = read_json(
        MODULE6_OUTPUTS / "weo_monthly_metrics_2026-06.json",
        {"report_month": "sample", "reports": [], "email_status": "NotAvailable"},
    )
    module7_summary = read_json(
        MODULE7_OUTPUTS / "external_integration_run_summary.json",
        {"quality_gate_passed": False, "accepted_imf_rows": 0, "accepted_bis_policy_rate_rows": 0},
    )
    module8_assessment = read_json(
        MODULE8_OUTPUTS / "dashboard_observability_assessment.json",
        {"passed": False, "passed_count": 0, "total_count": 0},
    )

    captured_at = datetime.now(timezone.utc).isoformat(timespec="seconds")

    return [
        {
            "event_time": captured_at,
            "system": "Module 6 WEO monthly reporting",
            "action": "Generated executive analytical reports",
            "entity": "WEO reports",
            "entity_count": len(module6_metrics.get("reports", [])),
            "control_result": module6_metrics.get("email_status", "Unknown"),
            "evidence_path": str(MODULE6_OUTPUTS / "weo_monthly_metrics_2026-06.json"),
        },
        {
            "event_time": captured_at,
            "system": "Module 7 external data integration",
            "action": "Validated IMF/BIS external data quality gate",
            "entity": "Accepted external data rows",
            "entity_count": int(module7_summary.get("accepted_imf_rows", 0))
            + int(module7_summary.get("accepted_bis_policy_rate_rows", 0)),
            "control_result": "Passed" if module7_summary.get("quality_gate_passed") else "Failed",
            "evidence_path": str(MODULE7_OUTPUTS / "external_integration_run_summary.json"),
        },
        {
            "event_time": captured_at,
            "system": "Module 8 monitoring dashboard",
            "action": "Assessed observability dashboard against standards",
            "entity": "Dashboard standards",
            "entity_count": int(module8_assessment.get("total_count", 0)),
            "control_result": "Passed" if module8_assessment.get("passed") else "ReviewRequired",
            "evidence_path": str(MODULE8_OUTPUTS / "dashboard_observability_assessment.json"),
        },
    ]


def build_evidence_pack(events: list[dict[str, Any]]) -> dict[str, Any]:
    """Summarise audit evidence for compliance review."""
    return {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "purpose": "Training evidence pack for regulated database and Python automation.",
        "privacy_note": "No passwords, tokens, or full personal identifiers are stored in this evidence pack.",
        "event_count": len(events),
        "events": events,
        "review_questions": [
            "Can we prove the automation ran?",
            "Can we prove data quality gates passed or failed?",
            "Can we prove report/dashboard outputs were produced?",
            "Can we identify where supporting evidence is stored?",
        ],
    }


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    events = build_audit_events()
    evidence_pack = build_evidence_pack(events)

    (OUTPUT_DIR / "audit_trail_sample.json").write_text(json.dumps(events, indent=2), encoding="utf-8")
    (OUTPUT_DIR / "compliance_evidence_pack.json").write_text(
        json.dumps(evidence_pack, indent=2),
        encoding="utf-8",
    )

    print(json.dumps(evidence_pack, indent=2))


if __name__ == "__main__":
    main()
