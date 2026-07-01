"""
Step 3: Parse IMF JSON into flat database-friendly rows.

Nested API responses are useful for APIs, but SQL tables normally need rows and
columns. This script converts IMF indicator/country/year values into rows.
"""

from __future__ import annotations

import json
from pathlib import Path

import pandas as pd
import requests


LAB_DIR = Path(__file__).resolve().parents[1]
OUTPUT_DIR = Path(__file__).resolve().parent / "outputs"
SAMPLE_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"
IMF_URL = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA"


def fetch_imf_data() -> dict:
    try:
        response = requests.get(
            IMF_URL,
            params={"periods": "2024,2025,2026"},
            headers={"Accept": "application/json"},
            timeout=20,
        )
        response.raise_for_status()
        payload = response.json()
        if not {"countries", "indicators", "values"}.issubset(payload):
            raise ValueError("Live IMF response shape differs from the teaching sample.")
        return payload
    except Exception as exc:
        print(f"Live IMF request did not complete: {exc}")
        print(f"Using local sample file: {SAMPLE_JSON}")
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))


def parse_imf_json(payload: dict) -> list[dict[str, object]]:
    indicator_code = "PCPIPCH"
    countries = payload["countries"]
    indicator_info = payload["indicators"][indicator_code]
    values = payload["values"][indicator_code]

    rows: list[dict[str, object]] = []
    for country_code, yearly_values in values.items():
        country_name = countries.get(country_code, country_code)
        for year, value in yearly_values.items():
            rows.append(
                {
                    "SourceName": "IMF DataMapper",
                    "CountryCode": country_code,
                    "CountryName": country_name,
                    "IndicatorCode": indicator_code,
                    "IndicatorName": indicator_info.get("label"),
                    "ObservationYear": int(year),
                    "ObservationValue": float(value),
                    "Unit": indicator_info.get("unit"),
                    "Frequency": "Annual",
                }
            )
    return rows


def main() -> None:
    payload = fetch_imf_data()
    rows = parse_imf_json(payload)
    frame = pd.DataFrame(rows)

    # gate validtion
    # insert into the db

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "03_imf_inflation_rows.csv"
    frame.to_csv(output_path, index=False)

    print("Parsed IMF rows:")
    print(frame)
    print(f"\nSaved to {output_path}")


if __name__ == "__main__":
    main()
