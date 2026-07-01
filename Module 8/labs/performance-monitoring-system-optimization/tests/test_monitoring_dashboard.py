from __future__ import annotations

import importlib.util
import sys
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(LAB_DIR))


def load_module(filename: str, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, LAB_DIR / filename)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def test_alert_level_classifies_normal_warning_critical():
    dashboard = load_module("06_monitoring_dashboard.py", "dashboard_test")

    assert dashboard.alert_level(5, 10, 20) == "Normal"
    assert dashboard.alert_level(10, 10, 20) == "Warning"
    assert dashboard.alert_level(25, 10, 20) == "Critical"


def test_capacity_projection_grows_rows_and_storage():
    capacity = load_module("05_capacity_planning_baseline.py", "capacity_test")

    projection = capacity.build_projection(
        current_rows=100,
        current_storage_mb=50,
        monthly_growth_rate=0.10,
        planning_months=3,
    )

    assert len(projection) == 3
    assert projection[0]["projected_rows"] == 110
    assert projection[-1]["projected_storage_mb"] > 50


def test_prior_module_workflow_observations_have_common_shape():
    sources = load_module("monitoring_data_sources.py", "sources_test")

    observations = sources.build_workflow_observations()

    assert len(observations) >= 2
    assert {"workflow_name", "status", "duration_seconds", "records_processed"}.issubset(observations[0])


def test_dashboard_renders_with_fallback_metrics(monkeypatch):
    dashboard = load_module("06_monitoring_dashboard.py", "dashboard_render_test")
    monkeypatch.setenv("DB_DRIVER", "Missing ODBC Driver")

    context = dashboard.render_dashboard()

    assert len(context["database_metrics"]) >= 3
    assert len(context["python_metrics"]) >= 3
    assert len(context["workflow_metrics"]) >= 3
    assert context["metric_summary"]["total"] >= 9
    assert len(context["workflow_observations"]) >= 2
    assert (LAB_DIR / "outputs" / "monitoring_dashboard.html").exists()
    assert (LAB_DIR / "outputs" / "monitoring_snapshot.json").exists()


def test_dashboard_assessment_passes_after_render(monkeypatch):
    dashboard = load_module("06_monitoring_dashboard.py", "dashboard_for_assessment_test")
    assessment_module = load_module("07_dashboard_observability_assessment.py", "assessment_test")
    monkeypatch.setenv("DB_DRIVER", "Missing ODBC Driver")

    snapshot = dashboard.render_dashboard()
    assessment = assessment_module.assess_snapshot(snapshot)

    assert assessment["passed"] is True
    assert assessment["passed_count"] == assessment["total_count"]
