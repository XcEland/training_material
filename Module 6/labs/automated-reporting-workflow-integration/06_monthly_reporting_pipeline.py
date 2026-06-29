"""
Module 6 automated monthly WEO reporting pipeline.

This controller intentionally stays small. Each report has its own file under
reports/, while shared work such as SQL connections, Jinja rendering, and email
delivery lives in database/ and services/.
"""

from __future__ import annotations

import argparse
import json
import time
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

from config.settings import DEFAULT_CONFIG, env_bool, load_settings
from database.connection import try_connect
from database.weo_repository import load_weo_to_sql
from database.weo_transform import load_weo_dataset
from reports.commodity_monitoring_report import generate_report as generate_commodity_report
from reports.inflation_risk_report import generate_report as generate_inflation_report
from reports.macro_outlook_report import generate_report as generate_macro_report
from reports.common import ReportArtifact
from services.email_service import all_recipients, send_or_preview_report_pack
from services.pdf_service import generate_pdf_reports
from services.weo_downloader import resolve_weo_workbook, update_release_manifest


REPORT_GENERATORS: dict[str, Callable[..., ReportArtifact]] = {
    "macro_outlook": generate_macro_report,
    "inflation_risk": generate_inflation_report,
    "commodity_monitoring": generate_commodity_report,
}


@dataclass
class PipelineResult:
    report_month: str
    status: str
    generated_reports: list[str]
    email_status: str
    started_at: str
    completed_at: str
    message: str


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, default=str), encoding="utf-8")


def append_run_log(config: dict[str, Any], payload: dict[str, Any]) -> None:
    log_path = config["paths"]["outputs"] / "monthly_report_run_log.jsonl"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with log_path.open("a", encoding="utf-8") as file:
        file.write(json.dumps(payload, default=str) + "\n")


def selected_report_ids(args: argparse.Namespace, config: dict[str, Any]) -> list[str]:
    if args.reports:
        return [item.strip() for item in args.reports.split(",") if item.strip()]
    ordered_reports = sorted(config["reports"], key=lambda report: report.get("order", 999))
    return [report["id"] for report in ordered_reports if report.get("enabled", True)]


def evaluate_phase2(
    artifacts: list[ReportArtifact],
    config: dict[str, Any],
    email_status: str,
    sql_load_status: str,
    pipeline_seconds: float,
) -> dict[str, Any]:
    thresholds = config["output_quality_thresholds"]
    benchmark_results = [
        {
            "benchmark": "Scheduling reliability logging present",
            "passed": True,
            "evidence": "JSONL run log records start time, completion time, status, output paths, and email status.",
        },
        {
            "benchmark": "Multiple professional reports generated",
            "passed": len(artifacts) >= thresholds["minimum_report_count"],
            "evidence": f"{len(artifacts)} reports generated; threshold is {thresholds['minimum_report_count']}.",
        },
        {
            "benchmark": "T-SQL extraction path available",
            "passed": sql_load_status == "LoadedToSql" or any(item.data_source.startswith("T-SQL") for item in artifacts),
            "evidence": f"SQL load status: {sql_load_status}. Report sources: {[item.data_source for item in artifacts]}.",
        },
        {
            "benchmark": "Stakeholder notification prepared",
            "passed": email_status in ("DryRunPreviewCreated", "Sent"),
            "evidence": f"Email status: {email_status}.",
        },
        {
            "benchmark": "Pipeline runtime within training benchmark",
            "passed": pipeline_seconds <= thresholds["maximum_pipeline_seconds"],
            "evidence": f"Pipeline completed in {pipeline_seconds:.2f} seconds.",
        },
    ]
    return {
        "benchmarks": benchmark_results,
        "passed_count": sum(1 for item in benchmark_results if item["passed"]),
        "total_count": len(benchmark_results),
    }


def run_pipeline(args: argparse.Namespace) -> PipelineResult:
    started_at = utc_now_iso()
    start_seconds = time.perf_counter()

    config = load_settings(args.config, args.env)
    if args.email_template:
        config.setdefault("email_templates", {})["selected"] = args.email_template

    for path in config["paths"].values():
        if isinstance(path, Path) and path.name in {"outputs", "html", "pdf", "email", "data"}:
            path.mkdir(parents=True, exist_ok=True)

    report_month = args.report_month or config["default_report_month"]
    dry_run_email = args.dry_run_email or not env_bool("SEND_EMAILS", default=False)

    workbook_path, download_info = resolve_weo_workbook(config, force_download=args.download_weo)
    dataset = load_weo_dataset(workbook_path)
    release_info = update_release_manifest(config, dataset["metadata"])

    engine = try_connect()
    refresh_data = args.refresh_data or (config["weo_dataset"].get("refresh_data_on_run", True) and not args.skip_refresh_data)
    sql_load_status = load_weo_to_sql(engine, dataset) if refresh_data else "SkippedByArgument"

    artifacts: list[ReportArtifact] = []
    for report_id in selected_report_ids(args, config):
        if report_id not in REPORT_GENERATORS:
            raise ValueError(f"Unknown report id: {report_id}. Valid options: {list(REPORT_GENERATORS)}")
        artifacts.append(REPORT_GENERATORS[report_id](engine, dataset, config, report_month))

    pdf_status = "NotRequested"
    if args.generate_pdf or config.get("output_formats", {}).get("generate_pdf", False):
        pdf_status = generate_pdf_reports(artifacts, config)

    email_status, email_preview_path = send_or_preview_report_pack(
        report_month,
        artifacts,
        config,
        dry_run_email,
        {"release": release_info, "download": download_info},
    )

    pipeline_seconds = round(time.perf_counter() - start_seconds, 2)
    evaluation = evaluate_phase2(artifacts, config, email_status, sql_load_status, pipeline_seconds)

    metrics_payload = {
        "report_month": report_month,
        "pipeline_seconds": pipeline_seconds,
        "download": download_info,
        "release": release_info,
        "sql_load_status": sql_load_status,
        "pdf_status": pdf_status,
        "reports": [asdict(item) for item in artifacts],
        "email_status": email_status,
        "email_preview_path": str(email_preview_path),
        "recipient_count": len(all_recipients(config)),
    }
    write_json(config["paths"]["outputs"] / f"weo_monthly_metrics_{report_month}.json", metrics_payload)
    write_json(
        config["paths"]["outputs"] / f"phase2_pipeline_evaluation_{report_month}.json",
        {**metrics_payload, **evaluation},
    )

    completed_at = utc_now_iso()
    result = PipelineResult(
        report_month=report_month,
        status="Succeeded",
        generated_reports=[str(item.html_path) for item in artifacts],
        email_status=email_status,
        started_at=started_at,
        completed_at=completed_at,
        message=f"Completed in {pipeline_seconds} seconds. SQL load status: {sql_load_status}.",
    )
    append_run_log(config, {**asdict(result), "evaluation": evaluation})
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the Module 6 WEO monthly reporting pipeline.")
    parser.add_argument("--report-month", help="Reporting cycle in YYYY-MM format. Example: 2026-06")
    parser.add_argument("--config", default=str(DEFAULT_CONFIG), help="Path to JSON reporting config.")
    parser.add_argument("--env", default=".env", help="Environment file name inside the lab folder.")
    parser.add_argument("--reports", help="Comma-separated report ids. Example: macro_outlook,inflation_risk")
    parser.add_argument("--email-template", help="Email template key from config.email_templates.available.")
    parser.add_argument("--refresh-data", action="store_true", help="Load transformed WEO data into SQL before reporting.")
    parser.add_argument("--skip-refresh-data", action="store_true", help="Skip SQL refresh and use current SQL/fallback data.")
    parser.add_argument("--download-weo", action="store_true", help="Download WEO workbook from WEO_DOWNLOAD_URL before processing.")
    parser.add_argument("--generate-pdf", action="store_true", help="Generate PDFs from HTML reports when WeasyPrint is installed.")
    parser.add_argument("--dry-run-email", action="store_true", help="Force email preview instead of SMTP delivery.")
    return parser.parse_args()


def main() -> None:
    try:
        result = run_pipeline(parse_args())
        print(json.dumps(asdict(result), indent=2))
    except Exception as exc:
        config = load_settings(DEFAULT_CONFIG, ".env")
        failed = PipelineResult(
            report_month="unknown",
            status="Failed",
            generated_reports=[],
            email_status="NotAttempted",
            started_at=utc_now_iso(),
            completed_at=utc_now_iso(),
            message=str(exc),
        )
        append_run_log(config, asdict(failed))
        raise


if __name__ == "__main__":
    main()
