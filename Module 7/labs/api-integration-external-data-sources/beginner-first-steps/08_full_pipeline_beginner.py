"""
Step 8: Run a small end-to-end IMF integration pipeline.

This combines:
- API consumption or local sample loading
- JSON parsing
- validation
- CSV output
- optional SQL Server loading
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd
import requests

from importlib import util


STEP_DIR = Path(__file__).resolve().parent
LAB_DIR = STEP_DIR.parents[0]
OUTPUT_DIR = STEP_DIR / "outputs"
SAMPLE_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"
IMF_URL = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA"


def load_step_module(filename: str, module_name: str):
    spec = util.spec_from_file_location(module_name, STEP_DIR / filename)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {filename}")
    module = util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def fetch_imf_data(offline: bool) -> dict:
    print("Step 1: Fetching IMF data...")
    if offline:
        print(f"Offline mode: using {SAMPLE_JSON}")
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))

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
        print("IMF data fetched successfully.")
        return payload
    except Exception as exc:
        print(f"Live request did not complete: {exc}")
        print(f"Using local sample file: {SAMPLE_JSON}")
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))


def save_outputs(accepted: list[dict[str, object]], rejected: list[dict[str, object]]) -> None:
    print("Step 4: Saving outputs...")
    OUTPUT_DIR.mkdir(exist_ok=True)
    pd.DataFrame(accepted).to_csv(OUTPUT_DIR / "08_accepted_imf_rows.csv", index=False)
    pd.DataFrame(rejected).to_json(OUTPUT_DIR / "08_rejected_imf_rows.json", orient="records", indent=2)
    print(f"Saved {OUTPUT_DIR / '08_accepted_imf_rows.csv'}")
    print(f"Saved {OUTPUT_DIR / '08_rejected_imf_rows.json'}")


def load_to_sql_server(rows: list[dict[str, object]]) -> None:
    loader = load_step_module("07_load_to_sql_server.py", "beginner_sql_loader")
    connection = loader.connect_to_sql_server()
    cursor = connection.cursor()
    loader.create_table_if_not_exists(cursor)
    loader.insert_imf_rows(cursor, rows)
    connection.commit()
    cursor.close()
    connection.close()
    print("SQL Server load completed.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the beginner IMF integration pipeline.")
    parser.add_argument("--offline", action="store_true", help="Use the local IMF sample JSON file.")
    parser.add_argument("--load-sql", action="store_true", help="Load accepted rows into SQL Server.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    parser_module = load_step_module("03_parse_imf_json.py", "beginner_imf_parser")
    validation_module = load_step_module("06_validate_before_database.py", "beginner_validator")

    payload = fetch_imf_data(args.offline)

    print("Step 2: Parsing IMF JSON...")
    rows = parser_module.parse_imf_json(payload)
    print(f"Parsed rows: {len(rows)}")

    print("Step 3: Validating rows...")
    accepted, rejected = validation_module.validate_imf_rows(rows)
    print(f"Accepted rows: {len(accepted)}")
    print(f"Rejected rows: {len(rejected)}")

    save_outputs(accepted, rejected)

    if args.load_sql:
        print("Step 5: Loading accepted rows into SQL Server...")
        load_to_sql_server(accepted)
    else:
        print("Database load skipped. Add --load-sql when SQL Server is ready.")


if __name__ == "__main__":
    main()
