"""
Beginner lab: JSON-only parsing with one data source.

Goal:
Read one IMF DataMapper-style JSON file and convert it into flat rows that
match a relational database table.

Local sample file to open in VS Code:
sample_data/imf_datamapper_weo_inflation_sample.json

Postman/browser URL represented by this sample:
GET https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA?periods=2024,2025,2026

This lab intentionally avoids XML, web scraping, SQL loading, and validation.
It focuses only on the basic JSON parsing pattern.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import pandas as pd


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"

# Use this URL in Postman to see the live IMF JSON shape when network access allows it.
# Method: GET
# Headers: Accept: application/json
# Note: Some classroom or corporate networks may receive HTTP 403 from IMF.
POSTMAN_IMF_URL = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA?periods=2024,2025,2026"


def load_json_file(path: Path) -> dict[str, Any]:
    """Load a JSON file into a Python dictionary."""
    text = path.read_text(encoding="utf-8")
    return json.loads(text)


def parse_imf_json_one_indicator(payload: dict[str, Any], indicator_code: str = "PCPIPCH") -> list[dict[str, Any]]:
    """
    Convert one IMF indicator from nested JSON into flat relational rows.

    The sample JSON shape is:

    values
      -> indicator code
        -> country code
          -> year
            -> value
    """
    countries = payload["countries"]
    indicator = payload["indicators"][indicator_code]
    yearly_values_by_country = payload["values"][indicator_code]

    rows: list[dict[str, Any]] = []
    for country_code, yearly_values in yearly_values_by_country.items():
        for year, value in yearly_values.items():
            rows.append(
                {
                    "SourceName": "IMF DataMapper Sample",
                    "CountryCode": country_code,
                    "CountryName": countries.get(country_code),
                    "IndicatorCode": indicator_code,
                    "IndicatorName": indicator["label"],
                    "ObservationYear": int(year),
                    "ObservationValue": float(value),
                    "Unit": indicator["unit"],
                    "Frequency": "Annual",
                }
            )
    return rows


def main() -> None:
    payload = load_json_file(SAMPLE_JSON)
    rows = parse_imf_json_one_indicator(payload)
    frame = pd.DataFrame(rows)

    print("Local JSON sample file:")
    print(SAMPLE_JSON)
    print()
    print("Postman GET URL for the live IMF API:")
    print(POSTMAN_IMF_URL)
    print()
    print("JSON-only parsing output:")
    print(frame)
    print()
    print("Relational columns:")
    print(list(frame.columns))


if __name__ == "__main__":
    main()
