"""
Beginner walkthrough: what are we securing in Module 9?

This script builds a small data inventory from the systems created earlier:
- Module 6 WEO report outputs and email preview status
- Module 7 IMF/BIS external integration quality summary
- Module 8 monitoring dashboard output

Security work starts by identifying data, access paths, and likely risks.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


LAB_DIR = Path(__file__).resolve().parent
REPO_ROOT = LAB_DIR.parents[2]
OUTPUT_DIR = LAB_DIR / "outputs"

MODULE6_OUTPUTS = REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / "outputs"
MODULE7_OUTPUTS = REPO_ROOT / "Module 7" / "labs" / "api-integration-external-data-sources" / "outputs"
MODULE8_OUTPUTS = REPO_ROOT / "Module 8" / "labs" / "performance-monitoring-system-optimization" / "outputs"


def read_json(path: Path, fallback: dict[str, Any]) -> dict[str, Any]:
    """Read JSON if the file exists; otherwise return a classroom fallback."""
    if not path.exists():
        return fallback
    return json.loads(path.read_text(encoding="utf-8"))


def classify_data_asset(name: str, source_path: Path, data_type: str, access_need: str) -> dict[str, str]:
    """
    Build one data inventory row.

    Beginner note:
    A data inventory is a list of assets, their sensitivity, and who should
    access them. Security controls come after this inventory.
    """
    if "email" in name.lower() or "recipient" in access_need.lower():
        classification = "Confidential"
    elif "quality" in name.lower() or "audit" in name.lower():
        classification = "Internal Control Evidence"
    else:
        classification = "Internal Analytical Data"

    return {
        "asset_name": name,
        "source_path": str(source_path),
        "data_type": data_type,
        "classification": classification,
        "minimum_access_need": access_need,
        "recommended_control": "least privilege role, audit trail, and no hardcoded credentials",
    }


def build_inventory() -> list[dict[str, str]]:
    """Create a beginner-friendly security inventory from prior modules."""
    module6_metrics = read_json(
        MODULE6_OUTPUTS / "weo_monthly_metrics_2026-06.json",
        {"recipient_count": 0, "reports": []},
    )
    module7_summary = read_json(
        MODULE7_OUTPUTS / "external_integration_run_summary.json",
        {"accepted_imf_rows": 0, "accepted_bis_policy_rate_rows": 0},
    )
    module8_snapshot = read_json(
        MODULE8_OUTPUTS / "monitoring_snapshot.json",
        {"database_metrics": [], "python_metrics": []},
    )

    inventory = [
        classify_data_asset(
            "Module 6 WEO executive reports",
            MODULE6_OUTPUTS / "html",
            "HTML analytical reports",
            "Executive, monetary policy, research, and reporting teams",
        ),
        classify_data_asset(
            "Module 6 report email preview",
            MODULE6_OUTPUTS / "email",
            f"stakeholder notification preview; recipients={module6_metrics.get('recipient_count', 0)}",
            "Only reporting operations staff and approved distribution owners",
        ),
        classify_data_asset(
            "Module 7 IMF/BIS accepted external data",
            MODULE7_OUTPUTS,
            (
                f"accepted rows: IMF={module7_summary.get('accepted_imf_rows', 0)}, "
                f"BIS={module7_summary.get('accepted_bis_policy_rate_rows', 0)}"
            ),
            "ETL service account, economists, and database reviewers",
        ),
        classify_data_asset(
            "Module 8 monitoring dashboard snapshot",
            MODULE8_OUTPUTS / "monitoring_snapshot.json",
            (
                f"database metrics={len(module8_snapshot.get('database_metrics', []))}; "
                f"python metrics={len(module8_snapshot.get('python_metrics', []))}"
            ),
            "Operations, DBA, and automation support teams",
        ),
    ]
    return inventory


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    inventory = build_inventory()
    output_path = OUTPUT_DIR / "security_data_inventory.json"
    output_path.write_text(json.dumps(inventory, indent=2), encoding="utf-8")

    print("Security data inventory:")
    print(json.dumps(inventory, indent=2))
    print(f"\nWritten to: {output_path}")


if __name__ == "__main__":
    main()
