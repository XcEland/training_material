"""
Prepare a deployable capstone artifact bundle.

The deployment portal in `deployment/capstone_portal.py` serves static evidence
from earlier modules. This script copies the most important outputs from Modules
6-9 into `deployment/published_artifacts/` so Docker can package them cleanly.
"""

from __future__ import annotations

import json
import shutil
from datetime import datetime, timezone
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parent
REPO_ROOT = LAB_DIR.parents[2]
DEPLOYMENT_DIR = LAB_DIR / "deployment"
PUBLISHED_DIR = DEPLOYMENT_DIR / "published_artifacts"
OUTPUT_PATH = LAB_DIR / "outputs" / "deployment_bundle_manifest.json"


ARTIFACTS = [
    {
        "source": REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / "outputs" / "weo_monthly_metrics_2026-06.json",
        "target": "module6_weo_monthly_metrics.json",
        "label": "Module 6 WEO reporting metrics",
    },
    {
        "source": REPO_ROOT / "Module 6" / "labs" / "automated-reporting-workflow-integration" / "outputs" / "monthly_report_run_log.jsonl",
        "target": "module6_monthly_report_run_log.jsonl",
        "label": "Module 6 reporting run log",
    },
    {
        "source": REPO_ROOT / "Module 8" / "labs" / "performance-monitoring-system-optimization" / "outputs" / "monitoring_dashboard.html",
        "target": "module8_monitoring_dashboard.html",
        "label": "Module 8 monitoring dashboard",
    },
    {
        "source": REPO_ROOT / "Module 8" / "labs" / "performance-monitoring-system-optimization" / "outputs" / "monitoring_snapshot.json",
        "target": "module8_monitoring_snapshot.json",
        "label": "Module 8 monitoring snapshot",
    },
    {
        "source": REPO_ROOT / "Module 9" / "labs" / "security-compliance-best-practices" / "outputs" / "security_assessment_report.json",
        "target": "module9_security_assessment_report.json",
        "label": "Module 9 security assessment",
    },
    {
        "source": REPO_ROOT / "Module 9" / "labs" / "security-compliance-best-practices" / "outputs" / "compliance_evidence_pack.json",
        "target": "module9_compliance_evidence_pack.json",
        "label": "Module 9 compliance evidence pack",
    },
    {
        "source": REPO_ROOT / "Module 9" / "labs" / "security-compliance-best-practices" / "outputs" / "kpi_roi_summary.json",
        "target": "module9_kpi_roi_summary.json",
        "label": "Module 9 KPI and ROI summary",
    },
]


def copy_artifacts() -> dict:
    """Copy available artifacts and produce a manifest."""
    PUBLISHED_DIR.mkdir(parents=True, exist_ok=True)
    copied = []
    missing = []

    for item in ARTIFACTS:
        source = item["source"]
        target = PUBLISHED_DIR / item["target"]
        if source.exists():
            shutil.copy2(source, target)
            copied.append(
                {
                    "label": item["label"],
                    "filename": item["target"],
                    "source": str(source),
                    "size_bytes": target.stat().st_size,
                }
            )
        else:
            missing.append({"label": item["label"], "source": str(source)})

    manifest = {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "published_artifacts_dir": str(PUBLISHED_DIR),
        "copied_count": len(copied),
        "missing_count": len(missing),
        "copied": copied,
        "missing": missing,
        "deployment_target": "DigitalOcean Droplet or DigitalOcean App Platform",
    }

    manifest_path = PUBLISHED_DIR / "artifact_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    OUTPUT_PATH.parent.mkdir(exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    return manifest


def main() -> None:
    manifest = copy_artifacts()
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
