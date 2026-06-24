"""
Advanced Module 7 exercise: external data integration pipeline.

The workflow:
1. Pull external API data or load local sample payloads.
2. Parse JSON and XML into relational rows.
3. Scrape authorised HTML into relational rows.
4. Validate records before database insertion.
5. Store accepted data in SQL Server when available.
6. Write offline output files and run logs for auditability.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd
import requests
from sqlalchemy import text

from db_utils import get_sqlalchemy_engine
from validation_rules import validate_api_observations, validate_market_rates


LAB_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = LAB_DIR / "outputs"
SAMPLE_JSON = LAB_DIR / "sample_data" / "world_bank_indicator_sample.json"
SAMPLE_XML = LAB_DIR / "sample_data" / "world_bank_indicator_sample.xml"
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_market_rates_sample.html"
WORLD_BANK_URL = "https://api.worldbank.org/v2/country/LSO;ZAF;BWA/indicator/FP.CPI.TOTL.ZG"


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def load_module(path: Path, module_name: str):
    """Load a teaching script whose filename starts with a number."""
    spec = importlib.util.spec_from_file_location(module_name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Cannot load module from {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def load_json_payload(offline: bool) -> list[Any]:
    """Fetch JSON from a live API or use the local sample."""
    if offline:
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))

    response = requests.get(
        WORLD_BANK_URL,
        params={"format": "json", "per_page": 20},
        headers={"User-Agent": "Trainingcred-Module7-Lab/1.0"},
        timeout=20,
    )
    response.raise_for_status()
    return response.json()


def load_xml_payload(offline: bool) -> str:
    """Fetch XML from a live API or use the local sample."""
    if offline:
        return SAMPLE_XML.read_text(encoding="utf-8")

    response = requests.get(
        WORLD_BANK_URL,
        params={"format": "xml", "per_page": 20},
        headers={"User-Agent": "Trainingcred-Module7-Lab/1.0"},
        timeout=20,
    )
    response.raise_for_status()
    return response.text


def prepare_external_rows(offline: bool) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Prepare accepted API rows, rejected API rows, and accepted market-rate rows."""
    parsers = load_module(LAB_DIR / "02_json_xml_parsing.py", "module7_parsers")
    scraper = load_module(LAB_DIR / "03_web_scraping_beautifulsoup.py", "module7_scraper")

    json_payload = load_json_payload(offline)
    xml_payload = load_xml_payload(offline)
    html_payload = SAMPLE_HTML.read_text(encoding="utf-8")

    # Parse JSON and XML. We keep both to demonstrate multiple payload formats.
    # The validation step removes duplicate business keys.
    json_rows = parsers.parse_world_bank_json(json_payload, source_name="World Bank API")
    xml_rows = parsers.parse_world_bank_xml(xml_payload, source_name="World Bank API")
    api_rows = json_rows + xml_rows
    market_rows = scraper.parse_market_rates_html(html_payload)

    accepted_api, rejected_api = validate_api_observations(api_rows)
    accepted_rates, rejected_rates = validate_market_rates(market_rows)
    rejected_all = pd.concat([rejected_api, rejected_rates], ignore_index=True)
    return accepted_api, rejected_all, accepted_rates


def write_offline_outputs(
    accepted_api: pd.DataFrame,
    rejected_rows: pd.DataFrame,
    accepted_rates: pd.DataFrame,
    run_summary: dict[str, Any],
) -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    accepted_api.to_json(OUTPUT_DIR / "accepted_api_observations.json", orient="records", indent=2)
    rejected_rows.to_json(OUTPUT_DIR / "external_data_quality_issues.json", orient="records", indent=2)
    accepted_rates.to_json(OUTPUT_DIR / "accepted_market_rates.json", orient="records", indent=2)
    (OUTPUT_DIR / "external_integration_run_summary.json").write_text(
        json.dumps(run_summary, indent=2),
        encoding="utf-8",
    )


def load_to_sql(
    accepted_api: pd.DataFrame,
    rejected_rows: pd.DataFrame,
    accepted_rates: pd.DataFrame,
    env_file: str,
) -> None:
    """Load accepted and rejected records into SQL Server."""
    engine = get_sqlalchemy_engine(env_file)
    with engine.begin() as conn:
        run_id = conn.execute(
            text(
                """
                INSERT INTO m7.ExternalIntegrationRunLog
                    (SourceName, Status, AcceptedRows, RejectedRows, Message)
                OUTPUT inserted.RunID
                VALUES
                    ('World Bank API + Authorised HTML', 'Running', :accepted, :rejected, 'External integration started');
                """
            ),
            {"accepted": len(accepted_api) + len(accepted_rates), "rejected": len(rejected_rows)},
        ).scalar_one()

        # Keep the training load idempotent by replacing the same source rows.
        conn.execute(text("DELETE FROM m7.ExternalApiObservations WHERE SourceName = 'World Bank API';"))
        conn.execute(text("DELETE FROM m7.WebScrapedMarketRates WHERE SourceName = 'Authorised Training HTML';"))

        if not accepted_api.empty:
            accepted_api.to_sql("ExternalApiObservations", conn, schema="m7", if_exists="append", index=False)
        if not accepted_rates.empty:
            accepted_rates.to_sql("WebScrapedMarketRates", conn, schema="m7", if_exists="append", index=False)

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
    accepted_api, rejected_rows, accepted_rates = prepare_external_rows(args.offline)
    run_summary = {
        "started_at": utc_now_iso(),
        "offline_mode": args.offline,
        "accepted_api_rows": int(len(accepted_api)),
        "accepted_market_rate_rows": int(len(accepted_rates)),
        "quality_issue_rows": int(len(rejected_rows)),
        "sql_load_attempted": not args.skip_sql,
    }

    write_offline_outputs(accepted_api, rejected_rows, accepted_rates, run_summary)

    if not args.skip_sql:
        try:
            load_to_sql(accepted_api, rejected_rows, accepted_rates, args.env)
            run_summary["sql_status"] = "Loaded"
        except Exception as exc:
            run_summary["sql_status"] = "SkippedOrFailed"
            run_summary["sql_error"] = str(exc)
            print("SQL load skipped or failed:", exc)
    else:
        run_summary["sql_status"] = "SkippedByArgument"

    run_summary["completed_at"] = utc_now_iso()
    run_summary["duration_seconds"] = round(time.perf_counter() - started, 2)
    write_offline_outputs(accepted_api, rejected_rows, accepted_rates, run_summary)
    return run_summary


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run Module 7 external integration pipeline.")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--offline", action="store_true", help="Use local sample payloads instead of live API calls.")
    parser.add_argument("--skip-sql", action="store_true", help="Do not attempt SQL Server load.")
    return parser.parse_args()


def main() -> None:
    summary = run_pipeline(parse_args())
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
