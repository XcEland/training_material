"""
Module 7 exercise: IMF/BIS external data integration pipeline.

The workflow:
1. Pull IMF DataMapper JSON and BIS CBPOL SDMX XML, or load local samples.
2. Parse JSON and XML/SDMX into relational rows.
3. Scrape an authorised HTML source registry with BeautifulSoup.
4. Validate records before database insertion.
5. Store accepted data in SQL Server when available.
6. Write offline output files and run logs for auditability.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd
from sqlalchemy import text

from data_quality_gate import gate_issues_to_rejection_rows, run_quality_gate, write_quality_alert
from db_utils import get_sqlalchemy_engine
from validation_rules import validate_authorised_sources, validate_imf_observations, validate_policy_rates


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_external_sources_sample.html"


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def load_module(path: Path, module_name: str):
    """Load a teaching script whose filename starts with a number."""
    spec = importlib.util.spec_from_file_location(module_name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Cannot load module from {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def prepare_external_rows(offline: bool) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Prepare accepted and rejected rows from all Module 7 sources."""
    api_client = load_module(LAB_DIR / "01_beginner_requests_api.py", "module7_api_client")
    parsers = load_module(LAB_DIR / "04_json_xml_combined_parsing.py", "module7_parsers")
    scraper = load_module(LAB_DIR / "07_web_scraping_beautifulsoup.py", "module7_scraper")

    # In live mode, corporate networks may block IMF DataMapper. If that
    # happens, fall back to the local sample so the exercise remains runnable.
    try:
        imf_payload = api_client.fetch_imf_weo_json(offline=offline)
        imf_source_name = "IMF DataMapper API" if not offline else "IMF DataMapper Sample"
    except Exception as exc:
        print("IMF live fetch failed. Using local sample:", exc)
        imf_payload = api_client.fetch_imf_weo_json(offline=True)
        imf_source_name = "IMF DataMapper Sample"

    try:
        bis_payload = api_client.fetch_bis_cbpol_sdmx(offline=offline)
        bis_source_name = "BIS CBPOL SDMX API" if not offline else "BIS CBPOL SDMX Sample"
    except Exception as exc:
        print("BIS live fetch failed. Using local sample:", exc)
        bis_payload = api_client.fetch_bis_cbpol_sdmx(offline=True)
        bis_source_name = "BIS CBPOL SDMX Sample"

    html_payload = SAMPLE_HTML.read_text(encoding="utf-8")

    imf_rows = parsers.parse_imf_datamapper_json(imf_payload, source_name=imf_source_name)
    policy_rows = parsers.parse_bis_cbpol_sdmx(bis_payload, source_name=bis_source_name)
    source_rows = scraper.parse_authorised_sources_html(html_payload)

    accepted_imf, rejected_imf = validate_imf_observations(imf_rows)
    accepted_policy, rejected_policy = validate_policy_rates(policy_rows)
    accepted_sources, rejected_sources = validate_authorised_sources(source_rows)
    rejected_all = pd.concat([rejected_imf, rejected_policy, rejected_sources], ignore_index=True)
    return accepted_imf, accepted_policy, accepted_sources, rejected_all


def write_offline_outputs(
    accepted_imf: pd.DataFrame,
    accepted_policy: pd.DataFrame,
    accepted_sources: pd.DataFrame,
    rejected_rows: pd.DataFrame,
    run_summary: dict[str, Any],
) -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    accepted_imf.to_json(OUTPUT_DIR / "accepted_imf_weo_observations.json", orient="records", indent=2)
    accepted_policy.to_json(OUTPUT_DIR / "accepted_bis_policy_rates.json", orient="records", indent=2)
    accepted_sources.to_json(OUTPUT_DIR / "accepted_authorised_sources.json", orient="records", indent=2)
    rejected_rows.to_json(OUTPUT_DIR / "external_data_quality_issues.json", orient="records", indent=2)
    (OUTPUT_DIR / "external_integration_run_summary.json").write_text(
        json.dumps(run_summary, indent=2),
        encoding="utf-8",
    )


def load_to_sql(
    accepted_imf: pd.DataFrame,
    accepted_policy: pd.DataFrame,
    accepted_sources: pd.DataFrame,
    rejected_rows: pd.DataFrame,
    env_file: str,
) -> None:
    """Load accepted and rejected records into SQL Server."""
    engine = get_sqlalchemy_engine(env_file)
    accepted_count = len(accepted_imf) + len(accepted_policy) + len(accepted_sources)
    with engine.begin() as conn:
        run_id = conn.execute(
            text(
                """
                INSERT INTO m7.ExternalIntegrationRunLog
                    (SourceName, Status, AcceptedRows, RejectedRows, Message)
                OUTPUT inserted.RunID
                VALUES
                    ('IMF DataMapper + BIS CBPOL + Authorised HTML', 'Running', :accepted, :rejected, 'External integration started');
                """
            ),
            {"accepted": accepted_count, "rejected": len(rejected_rows)},
        ).scalar_one()

        # Keep the training load idempotent by replacing rows from these sources.
        conn.execute(text("DELETE FROM m7.ImfWeoIndicators WHERE SourceName LIKE 'IMF DataMapper%';"))
        conn.execute(text("DELETE FROM m7.BisPolicyRates WHERE SourceName LIKE 'BIS CBPOL%';"))
        conn.execute(text("DELETE FROM m7.AuthorisedWebSources WHERE SourceName = 'Authorised Training HTML';"))

        if not accepted_imf.empty:
            accepted_imf.to_sql("ImfWeoIndicators", conn, schema="m7", if_exists="append", index=False)
        if not accepted_policy.empty:
            accepted_policy.to_sql("BisPolicyRates", conn, schema="m7", if_exists="append", index=False)
        if not accepted_sources.empty:
            accepted_sources.to_sql("AuthorisedWebSources", conn, schema="m7", if_exists="append", index=False)

        if not rejected_rows.empty:
            quality_rows = rejected_rows.copy()
            quality_rows["RunID"] = run_id
            quality_rows["SourceName"] = "External Integration Pipeline"
            quality_rows = quality_rows.rename(
                columns={
                    "record_key": "RecordKey",
                    "severity": "Severity",
                    "rule_name": "RuleName",
                    "message": "Message",
                }
            )[["RunID", "SourceName", "RecordKey", "Severity", "RuleName", "Message"]]
            quality_rows.to_sql("ExternalDataQualityLog", conn, schema="m7", if_exists="append", index=False)

        conn.execute(
            text(
                """
                UPDATE m7.ExternalIntegrationRunLog
                SET CompletedAt = SYSUTCDATETIME(),
                    Status = 'Succeeded',
                    Message = 'External integration completed successfully'
                WHERE RunID = :run_id;
                """
            ),
            {"run_id": run_id},
        )


def run_pipeline(args: argparse.Namespace) -> dict[str, Any]:
    started = time.perf_counter()
    accepted_imf, accepted_policy, accepted_sources, rejected_rows = prepare_external_rows(args.offline)
    quality_gate_passed, gate_issues = run_quality_gate(accepted_imf, accepted_policy, accepted_sources)
    gate_rejections = gate_issues_to_rejection_rows(gate_issues)
    if not gate_rejections.empty:
        rejected_rows = pd.concat([rejected_rows, gate_rejections], ignore_index=True)

    alert_path = OUTPUT_DIR / "external_data_quality_alert.json"
    run_summary = {
        "started_at": utc_now_iso(),
        "offline_mode": args.offline,
        "accepted_imf_rows": int(len(accepted_imf)),
        "accepted_bis_policy_rate_rows": int(len(accepted_policy)),
        "accepted_authorised_source_rows": int(len(accepted_sources)),
        "quality_issue_rows": int(len(rejected_rows)),
        "quality_gate_passed": quality_gate_passed,
        "quality_alert_path": str(alert_path),
        "sql_load_attempted": not args.skip_sql,
    }

    write_quality_alert(alert_path, quality_gate_passed, gate_issues)
    write_offline_outputs(accepted_imf, accepted_policy, accepted_sources, rejected_rows, run_summary)

    if not quality_gate_passed:
        run_summary["sql_status"] = "SkippedQualityGateFailed"
    elif not args.skip_sql:
        try:
            load_to_sql(accepted_imf, accepted_policy, accepted_sources, rejected_rows, args.env)
            run_summary["sql_status"] = "Loaded"
        except Exception as exc:
            run_summary["sql_status"] = "SkippedOrFailed"
            run_summary["sql_error"] = str(exc)
            print("SQL load skipped or failed:", exc)
    else:
        run_summary["sql_status"] = "SkippedByArgument"

    run_summary["completed_at"] = utc_now_iso()
    run_summary["duration_seconds"] = round(time.perf_counter() - started, 2)
    write_quality_alert(alert_path, quality_gate_passed, gate_issues)
    write_offline_outputs(accepted_imf, accepted_policy, accepted_sources, rejected_rows, run_summary)
    return run_summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Module 7 IMF/BIS external integration pipeline.")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--offline", action="store_true", help="Use local sample payloads instead of live API calls.")
    parser.add_argument("--skip-sql", action="store_true", help="Do not attempt SQL Server load.")
    return parser.parse_args()


def main() -> None:
    summary = run_pipeline(parse_args())
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
