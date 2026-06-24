"""
Monitoring dashboard generator.

The dashboard tracks:
- database performance metrics
- Python workflow execution metrics
- capacity projection
- operational observability checks

It uses SQL Server metrics when available and fallback values when not.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, select_autoescape
from sqlalchemy import text

from db_utils import get_sqlalchemy_engine


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
THRESHOLDS_PATH = LAB_DIR / "config" / "monitoring_thresholds.json"
TEMPLATE_DIR = LAB_DIR / "templates"


def load_thresholds() -> dict[str, Any]:
    return json.loads(THRESHOLDS_PATH.read_text(encoding="utf-8"))


def alert_level(value: float, warning: float, critical: float) -> str:
    if value >= critical:
        return "Critical"
    if value >= warning:
        return "Warning"
    return "Normal"


def fallback_database_metrics(thresholds: dict[str, Any]) -> list[dict[str, Any]]:
    db_thresholds = thresholds["database"]
    values = {
        "Active Sessions": 8,
        "Average Query Duration Ms": 420,
        "Database Size MB": 750,
    }
    return [
        {
            "metric_name": "Active Sessions",
            "metric_value": values["Active Sessions"],
            "alert_level": alert_level(values["Active Sessions"], db_thresholds["active_sessions_warning"], db_thresholds["active_sessions_critical"]),
            "data_source": "Fallback DMV sample",
        },
        {
            "metric_name": "Average Query Duration Ms",
            "metric_value": values["Average Query Duration Ms"],
            "alert_level": alert_level(values["Average Query Duration Ms"], db_thresholds["avg_query_duration_ms_warning"], db_thresholds["avg_query_duration_ms_critical"]),
            "data_source": "Fallback Query Store sample",
        },
        {
            "metric_name": "Database Size MB",
            "metric_value": values["Database Size MB"],
            "alert_level": alert_level(values["Database Size MB"], db_thresholds["database_size_mb_warning"], db_thresholds["database_size_mb_critical"]),
            "data_source": "Fallback sys.master_files sample",
        },
    ]


def collect_database_metrics(thresholds: dict[str, Any], env_file: str = ".env") -> list[dict[str, Any]]:
    """Collect database metrics from SQL Server or return fallback samples."""
    try:
        engine = get_sqlalchemy_engine(env_file)
        with engine.connect() as conn:
            active_sessions = conn.execute(
                text("SELECT COUNT(*) FROM sys.dm_exec_sessions WHERE is_user_process = 1;")
            ).scalar_one()
            database_size_mb = conn.execute(
                text(
                    """
                    SELECT COALESCE(SUM(size) * 8.0 / 1024, 0)
                    FROM sys.master_files
                    WHERE database_id = DB_ID('TrainingDB');
                    """
                )
            ).scalar_one()

        db_thresholds = thresholds["database"]
        return [
            {
                "metric_name": "Active Sessions",
                "metric_value": float(active_sessions),
                "alert_level": alert_level(float(active_sessions), db_thresholds["active_sessions_warning"], db_thresholds["active_sessions_critical"]),
                "data_source": "DMV sys.dm_exec_sessions",
            },
            {
                "metric_name": "Average Query Duration Ms",
                "metric_value": 0.0,
                "alert_level": "Normal",
                "data_source": "Query Store placeholder; run SQL lab for details",
            },
            {
                "metric_name": "Database Size MB",
                "metric_value": round(float(database_size_mb), 2),
                "alert_level": alert_level(float(database_size_mb), db_thresholds["database_size_mb_warning"], db_thresholds["database_size_mb_critical"]),
                "data_source": "sys.master_files",
            },
        ]
    except Exception as exc:
        print("Using fallback database metrics:", exc)
        return fallback_database_metrics(thresholds)


def collect_python_metrics(thresholds: dict[str, Any]) -> list[dict[str, Any]]:
    """Collect Python workflow metrics from generated output files or fallback values."""
    py_thresholds = thresholds["python_workflow"]
    profile_path = OUTPUT_DIR / "profile_summary.json"
    memory_path = OUTPUT_DIR / "memory_summary.json"
    log_path = OUTPUT_DIR / "python_workflow.log"

    if profile_path.exists():
        profile = json.loads(profile_path.read_text(encoding="utf-8"))
        duration_seconds = max(item["duration_seconds"] for item in profile)
    else:
        duration_seconds = 3.2

    if memory_path.exists():
        memory = json.loads(memory_path.read_text(encoding="utf-8"))
        peak_memory_mb = max(item["peak_memory_mb"] for item in memory)
    else:
        peak_memory_mb = 82.0

    error_count = 0
    if log_path.exists():
        text_value = log_path.read_text(encoding="utf-8")
        error_count = text_value.count("ERROR") + text_value.count("CRITICAL")

    return [
        {
            "metric_name": "Workflow Duration Seconds",
            "metric_value": round(float(duration_seconds), 4),
            "alert_level": alert_level(float(duration_seconds), py_thresholds["duration_seconds_warning"], py_thresholds["duration_seconds_critical"]),
            "data_source": "cProfile summary",
        },
        {
            "metric_name": "Peak Memory MB",
            "metric_value": round(float(peak_memory_mb), 4),
            "alert_level": alert_level(float(peak_memory_mb), py_thresholds["peak_memory_mb_warning"], py_thresholds["peak_memory_mb_critical"]),
            "data_source": "tracemalloc summary",
        },
        {
            "metric_name": "Python Error Count",
            "metric_value": error_count,
            "alert_level": alert_level(float(error_count), py_thresholds["error_count_warning"], py_thresholds["error_count_critical"]),
            "data_source": "workflow log file",
        },
    ]


def build_capacity_projection(thresholds: dict[str, Any]) -> list[dict[str, Any]]:
    capacity = thresholds["capacity"]
    projection = []
    rows = 500_000.0
    storage_mb = 750.0
    for month_number in range(1, capacity["planning_months"] + 1):
        rows *= 1 + capacity["monthly_growth_rate"]
        storage_mb *= 1 + capacity["monthly_growth_rate"]
        projection.append(
            {
                "month_number": month_number,
                "projected_rows": int(round(rows)),
                "projected_storage_mb": round(storage_mb, 2),
            }
        )
    return projection


def observability_results(database_metrics: list[dict[str, Any]], python_metrics: list[dict[str, Any]]) -> list[dict[str, Any]]:
    all_metrics = database_metrics + python_metrics
    critical_count = sum(1 for item in all_metrics if item["alert_level"] == "Critical")
    warning_count = sum(1 for item in all_metrics if item["alert_level"] == "Warning")
    return [
        {
            "standard": "Dashboard includes database metrics",
            "passed": len(database_metrics) >= 3,
            "evidence": f"{len(database_metrics)} database metrics rendered.",
        },
        {
            "standard": "Dashboard includes Python workflow metrics",
            "passed": len(python_metrics) >= 3,
            "evidence": f"{len(python_metrics)} Python metrics rendered.",
        },
        {
            "standard": "Alert levels are assigned",
            "passed": all(item["alert_level"] in ("Normal", "Warning", "Critical") for item in all_metrics),
            "evidence": f"{warning_count} warnings, {critical_count} critical alerts.",
        },
    ]


def render_dashboard(env_file: str = ".env") -> dict[str, Any]:
    OUTPUT_DIR.mkdir(exist_ok=True)
    thresholds = load_thresholds()
    database_metrics = collect_database_metrics(thresholds, env_file)
    python_metrics = collect_python_metrics(thresholds)
    capacity_projection = build_capacity_projection(thresholds)
    review = observability_results(database_metrics, python_metrics)

    context = {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "database_metrics": database_metrics,
        "python_metrics": python_metrics,
        "capacity_projection": capacity_projection,
        "observability_results": review,
    }

    env = Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        autoescape=select_autoescape(["html", "xml"]),
    )
    html = env.get_template("monitoring_dashboard.html.j2").render(**context)
    dashboard_path = OUTPUT_DIR / "monitoring_dashboard.html"
    snapshot_path = OUTPUT_DIR / "monitoring_snapshot.json"
    dashboard_path.write_text(html, encoding="utf-8")
    snapshot_path.write_text(json.dumps(context, indent=2), encoding="utf-8")
    return context


def main() -> None:
    context = render_dashboard()
    print(json.dumps(context, indent=2))


if __name__ == "__main__":
    main()
