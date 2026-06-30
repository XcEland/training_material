"""
Step 1: Make a basic API GET request with requests.

This script shows the smallest API pattern:
- define a URL
- send requests.get()
- inspect the status code
- convert JSON text into a Python dictionary
"""

from __future__ import annotations

import json
from pathlib import Path

import requests


LAB_DIR = Path(__file__).resolve().parents[1]
SAMPLE_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"

url = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA"
params = {"periods": "2024,2025,2026"}


def get_json_payload() -> dict:
    try:
        response = requests.get(url, params=params, timeout=20)

        print("Requested URL:")
        print(response.url)

        print("\nStatus code:")
        print(response.status_code)

        response.raise_for_status()
        return response.json()
    except Exception as exc:
        print("\nLive API request did not complete.")
        print(f"Reason: {exc}")
        print(f"Using local sample file instead: {SAMPLE_JSON}")
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))


def main() -> None:
    data = get_json_payload()

    print("\nTop-level keys in the JSON:")
    print(data.keys())

    print("\nSmall preview:")
    print(json.dumps(data, indent=2)[:1200])


if __name__ == "__main__":
    main()
