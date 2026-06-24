from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path


LAB_DIR = Path(__file__).resolve().parents[1]
SAMPLE_DIR = LAB_DIR / "sample_data"
sys.path.insert(0, str(LAB_DIR))


def load_module(filename: str, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, LAB_DIR / filename)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def test_json_parser_maps_nested_records_to_relational_rows():
    parser = load_module("02_json_xml_parsing.py", "parser_json_test")
    payload = json.loads((SAMPLE_DIR / "world_bank_indicator_sample.json").read_text(encoding="utf-8"))

    rows = parser.parse_world_bank_json(payload)

    assert len(rows) == 4
    assert rows[0]["CountryCode"] == "LSO"
    assert rows[0]["IndicatorCode"] == "FP.CPI.TOTL.ZG"
    assert rows[0]["ObservationYear"] == "2025"


def test_xml_parser_maps_namespaced_records_to_relational_rows():
    parser = load_module("02_json_xml_parsing.py", "parser_xml_test")
    xml_text = (SAMPLE_DIR / "world_bank_indicator_sample.xml").read_text(encoding="utf-8")

    rows = parser.parse_world_bank_xml(xml_text)

    assert len(rows) == 4
    assert rows[0]["CountryCode"] == "LSO"
    assert rows[0]["ObservationValue"] == 6.2


def test_beautifulsoup_scraper_extracts_authorised_market_rates():
    scraper = load_module("03_web_scraping_beautifulsoup.py", "scraper_test")
    html_text = (SAMPLE_DIR / "authorised_market_rates_sample.html").read_text(encoding="utf-8")

    rows = scraper.parse_market_rates_html(html_text)

    assert len(rows) == 3
    assert rows[0]["CurrencyCode"] == "USD"
    assert rows[0]["SellRate"] >= rows[0]["BuyRate"]


def test_validation_rejects_missing_values_and_duplicates():
    from validation_rules import validate_api_observations

    rows = [
        {
            "SourceName": "Test",
            "CountryCode": "LSO",
            "CountryName": "Lesotho",
            "IndicatorCode": "TEST.IND",
            "IndicatorName": "Test indicator",
            "ObservationYear": "2025",
            "ObservationValue": 1.2,
        },
        {
            "SourceName": "Test",
            "CountryCode": "LSO",
            "CountryName": "Lesotho",
            "IndicatorCode": "TEST.IND",
            "IndicatorName": "Test indicator",
            "ObservationYear": "2025",
            "ObservationValue": 1.2,
        },
        {
            "SourceName": "Test",
            "CountryCode": "BWA",
            "CountryName": "Botswana",
            "IndicatorCode": "TEST.IND",
            "IndicatorName": "Test indicator",
            "ObservationYear": "2025",
            "ObservationValue": None,
        },
    ]

    accepted, rejected = validate_api_observations(rows)

    assert len(accepted) == 1
    assert len(rejected) >= 2
    assert "DuplicateBusinessKey" in set(rejected["rule_name"])


def test_pipeline_runs_offline_without_sql():
    pipeline = load_module("05_external_data_integration_pipeline.py", "pipeline_test")

    class Args:
        env = ".env"
        offline = True
        skip_sql = True

    summary = pipeline.run_pipeline(Args())

    assert summary["accepted_api_rows"] >= 3
    assert summary["accepted_market_rate_rows"] == 3
    assert summary["quality_issue_rows"] >= 1
    assert summary["sql_status"] == "SkippedByArgument"
