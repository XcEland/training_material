"""
Walkthrough: loading monitoring data from previous modules.

Before building dashboards, inspect how monitoring data is loaded. This script
reads:
- JSON Lines from Module 6 scheduled WEO reporting runs
- JSON summaries from Module 6 and Module 7
- quality gate alerts from Module 7

Run:
    python 00_monitoring_data_walkthrough.py
"""

from __future__ import annotations

import json
from pathlib import Path

from monitoring_data_sources import (
    MODULE6_OUTPUTS,
    MODULE7_OUTPUTS,
    build_workflow_observations,
    load_latest_module6_run,
    load_module6_metrics,
    load_module7_quality_alert,
    load_module7_summary,
)


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)

    # These paths show where the monitoring data comes from.
    print("Module 6 outputs folder:", MODULE6_OUTPUTS)
    print("Module 7 outputs folder:", MODULE7_OUTPUTS)

    # Load one file at a time so the structure is easy to inspect.
    module6_run = load_latest_module6_run()
    module6_metrics = load_module6_metrics()
    module7_summary = load_module7_summary()
    module7_quality_alert = load_module7_quality_alert()

    print("\nLatest Module 6 run status:", module6_run.get("status"))
    print("Module 6 generated reports:", len(module6_run.get("generated_reports", [])))
    print("Module 6 pipeline seconds:", module6_metrics.get("pipeline_seconds"))
    print("Module 7 accepted IMF rows:", module7_summary.get("accepted_imf_rows"))
    print("Module 7 quality gate passed:", module7_quality_alert.get("quality_gate_passed"))

    # The dashboard needs a common monitoring shape, so we map both workflows
    # into the same set of columns.
    observations = build_workflow_observations()

    output_path = OUTPUT_DIR / "workflow_observations.json"
    output_path.write_text(json.dumps(observations, indent=2), encoding="utf-8")
    print("\nWorkflow observations written to:", output_path)
    print(json.dumps(observations, indent=2))


if __name__ == "__main__":
    main()
