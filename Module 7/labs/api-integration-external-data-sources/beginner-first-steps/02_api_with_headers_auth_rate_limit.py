"""
Step 2: Add headers, optional authentication, timeout, and rate limiting.

Headers tell the API what format the script wants back.
Rate limiting pauses before requests so external services are not overloaded.
"""

from __future__ import annotations

import json
import os
import time
from pathlib import Path

import requests
from dotenv import load_dotenv


LAB_DIR = Path(__file__).resolve().parents[1]
SAMPLE_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"
SAMPLE_XML = LAB_DIR / "sample_data" / "bis_cbpol_sdmx_generic_sample.xml"

IMF_URL = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA"
BIS_URL = "https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA"


def wait_before_request(seconds: float = 1.0) -> None:
    print(f"Waiting {seconds} second(s) before making the request...")
    time.sleep(seconds)


def build_headers(accept_type: str) -> dict[str, str]:
    headers = {
        "Accept": accept_type,
        "User-Agent": os.getenv("EXTERNAL_API_USER_AGENT", "Module7-Beginner-Lab/1.0"),
    }

    api_key = os.getenv("EXTERNAL_API_KEY")
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"

    return headers


def get_imf_json() -> dict:
    wait_before_request(float(os.getenv("API_MIN_SECONDS_BETWEEN_CALLS", "1")))
    try:
        response = requests.get(
            IMF_URL,
            params={"periods": "2024,2025,2026"},
            headers=build_headers("application/json"),
            timeout=20,
        )
        print("IMF status code:", response.status_code)
        response.raise_for_status()
        return response.json()
    except Exception as exc:
        print(f"IMF live request did not complete: {exc}")
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))


def get_bis_xml() -> str:
    wait_before_request(float(os.getenv("API_MIN_SECONDS_BETWEEN_CALLS", "1")))
    try:
        response = requests.get(
            BIS_URL,
            params={"startPeriod": "2024-01", "endPeriod": "2024-12", "detail": "full"},
            headers=build_headers("application/xml"),
            timeout=30,
        )
        print("BIS status code:", response.status_code)
        response.raise_for_status()
        return response.text
    except Exception as exc:
        print(f"BIS live request did not complete: {exc}")
        return SAMPLE_XML.read_text(encoding="utf-8")


def main() -> None:
    load_dotenv(LAB_DIR / ".env")

    imf_data = get_imf_json()
    print("\nIMF JSON keys:")
    print(imf_data.keys())

    bis_xml = get_bis_xml()
    print("\nFirst 500 characters of BIS XML:")
    print(bis_xml[:500])


if __name__ == "__main__":
    main()
