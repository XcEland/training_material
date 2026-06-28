from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from datetime import date


LAB_DIR = Path(__file__).resolve().parents[1]
SAMPLE_DIR = LAB_DIR / "sample_data"
sys.path.insert(0, str(LAB_DIR))


def load_module(filename: str, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, LAB_DIR / filename)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def test_imf_json_parser_maps_nested_records_to_relational_rows():
    parser = load_module("02_json_xml_parsing.py", "parser_json_test")
    payload = json.loads((SAMPLE_DIR / "imf_datamapper_weo_inflation_sample.json").read_text(encoding="utf-8"))

    rows = parser.parse_imf_datamapper_json(payload)

    assert len(rows) == 24
    assert rows[0]["CountryCode"] == "LSO"
    assert rows[0]["IndicatorCode"] == "PCPIPCH"
    assert rows[0]["ObservationYear"] == "2024"


def test_beginner_json_only_parser_maps_one_indicator():
    parser = load_module("02a_json_only_imf_parsing.py", "beginner_json_test")
    payload = json.loads((SAMPLE_DIR / "imf_datamapper_weo_inflation_sample.json").read_text(encoding="utf-8"))

    rows = parser.parse_imf_json_one_indicator(payload)

    assert len(rows) == 12
    assert rows[0]["IndicatorCode"] == "PCPIPCH"
    assert rows[0]["Frequency"] == "Annual"


def test_bis_sdmx_parser_maps_generic_xml_to_policy_rate_rows():
    parser = load_module("02_json_xml_parsing.py", "parser_xml_test")
    xml_text = (SAMPLE_DIR / "bis_cbpol_sdmx_generic_sample.xml").read_text(encoding="utf-8")

    rows = parser.parse_bis_cbpol_sdmx(xml_text)

    assert len(rows) == 6
    assert rows[0]["ReferenceArea"] == "GB"
    assert rows[0]["PolicyRate"] == 3.75


def test_beginner_xml_only_parser_maps_policy_rate_rows():
    parser = load_module("02b_xml_only_bis_parsing.py", "beginner_xml_test")
    root = parser.load_xml_file(SAMPLE_DIR / "bis_cbpol_sdmx_generic_sample.xml")

    rows = parser.parse_bis_policy_rate_xml(root)

    assert len(rows) == 6
    assert rows[0]["ReferenceArea"] == "GB"
    assert rows[0]["ObservationStatus"] == "A"


def test_beautifulsoup_scraper_extracts_authorised_sources():
    scraper = load_module("03_web_scraping_beautifulsoup.py", "scraper_test")
    html_text = (SAMPLE_DIR / "authorised_external_sources_sample.html").read_text(encoding="utf-8")

    rows = scraper.parse_authorised_sources_html(html_text)

    assert len(rows) == 3
    assert rows[0]["ExternalSourceName"] == "IMF DataMapper API"
    assert "Approved" in rows[0]["PermissionStatus"]


def test_beginner_html_loading_inspects_page():
    scraper = load_module("03a_html_loading_basics.py", "beginner_html_loading_test")
    html_text = (SAMPLE_DIR / "authorised_external_sources_sample.html").read_text(encoding="utf-8")

    page_info = scraper.inspect_html_page(html_text)

    assert page_info["page_title"] == "Authorised External Data Sources"
    assert page_info["table_row_count"] == 3


def test_beginner_beautifulsoup_table_extracts_records():
    scraper = load_module("03b_beautifulsoup_table_basics.py", "beginner_bs_table_test")
    from bs4 import BeautifulSoup

    html_text = (SAMPLE_DIR / "authorised_external_sources_sample.html").read_text(encoding="utf-8")
    soup = BeautifulSoup(html_text, "html.parser")

    headers = scraper.extract_table_headers(soup)
    table_rows = scraper.extract_table_rows(soup)
    records = scraper.table_to_dictionaries(headers, table_rows)

    assert headers[0] == "Source Name"
    assert len(records) == 3
    assert records[0]["Source Name"] == "IMF DataMapper API"


def test_beginner_scrapy_concepts_bridge_yields_items():
    scraper = load_module("04a_scrapy_concepts_basics.py", "beginner_scrapy_concepts_test")
    html_text = (SAMPLE_DIR / "authorised_external_sources_sample.html").read_text(encoding="utf-8")

    concepts = dict(scraper.explain_scrapy_concepts())
    items = scraper.simulate_spider_parse(html_text)

    assert "Spider" in concepts
    assert "DOWNLOAD_DELAY" in concepts
    assert len(items) == 3
    assert items[0]["ExternalSourceName"] == "IMF DataMapper API"


def test_validation_rejects_missing_values_and_duplicates():
    from validation_rules import validate_imf_observations

    rows = [
        {
            "SourceName": "Test",
            "CountryCode": "LSO",
            "CountryName": "Lesotho",
            "IndicatorCode": "PCPIPCH",
            "IndicatorName": "Inflation",
            "ObservationYear": "2025",
            "ObservationValue": 1.2,
            "Unit": "Percent change",
            "Frequency": "Annual",
        },
        {
            "SourceName": "Test",
            "CountryCode": "LSO",
            "CountryName": "Lesotho",
            "IndicatorCode": "PCPIPCH",
            "IndicatorName": "Inflation",
            "ObservationYear": "2025",
            "ObservationValue": 1.2,
            "Unit": "Percent change",
            "Frequency": "Annual",
        },
        {
            "SourceName": "Test",
            "CountryCode": "BWA",
            "CountryName": "Botswana",
            "IndicatorCode": "PCPIPCH",
            "IndicatorName": "Inflation",
            "ObservationYear": "2025",
            "ObservationValue": None,
            "Unit": "Percent change",
            "Frequency": "Annual",
        },
    ]

    accepted, rejected = validate_imf_observations(rows)

    assert len(accepted) == 1
    assert len(rejected) >= 2
    assert "DuplicateBusinessKey" in set(rejected["rule_name"])


def test_quality_gate_passes_clean_offline_data():
    from data_quality_gate import run_quality_gate

    pipeline = load_module("05_external_data_integration_pipeline.py", "pipeline_quality_gate_test")
    accepted_imf, accepted_policy, accepted_sources, _ = pipeline.prepare_external_rows(offline=True)

    passed, issues = run_quality_gate(
        accepted_imf,
        accepted_policy,
        accepted_sources,
        today=date(2026, 6, 27),
    )

    assert passed is True
    assert issues.empty


def test_quality_gate_fails_stale_policy_rates():
    from data_quality_gate import gate_issues_to_rejection_rows, run_quality_gate

    pipeline = load_module("05_external_data_integration_pipeline.py", "pipeline_quality_gate_fail_test")
    accepted_imf, accepted_policy, accepted_sources, _ = pipeline.prepare_external_rows(offline=True)
    accepted_policy["ObservationDate"] = "2020-01-01"

    passed, issues = run_quality_gate(
        accepted_imf,
        accepted_policy,
        accepted_sources,
        today=date(2026, 6, 27),
    )
    rejection_rows = gate_issues_to_rejection_rows(issues)

    assert passed is False
    assert "Timeliness" in set(issues["rule_name"])
    assert not rejection_rows.empty


def test_pipeline_runs_offline_without_sql():
    pipeline = load_module("05_external_data_integration_pipeline.py", "pipeline_test")

    class Args:
        env = ".env"
        offline = True
        skip_sql = True

    summary = pipeline.run_pipeline(Args())

    assert summary["accepted_imf_rows"] == 24
    assert summary["accepted_bis_policy_rate_rows"] == 6
    assert summary["accepted_authorised_source_rows"] == 3
    assert summary["quality_gate_passed"] is True
    assert summary["sql_status"] == "SkippedByArgument"
