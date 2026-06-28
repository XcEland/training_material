"""
Beginner REST API example with requests.

Concepts covered:
- GET requests
- query parameters
- authentication headers
- timeouts
- response status handling
- rate limiting
- offline fallback data

Security note:
API credentials must never be hard-coded in Python scripts. Store keys and
tokens in environment variables or a secrets manager, then load them with
os.getenv() at runtime. Before building a production API consumer, confirm the
authentication mechanism and the provider's rate-limit policy.

The live examples use IMF DataMapper JSON and BIS CBPOL SDMX XML. The same
functions can load local sample payloads when internet access is unavailable.
"""

from __future__ import annotations

import argparse
import json
import os
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import requests
from dotenv import load_dotenv


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_IMF_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"
SAMPLE_BIS_XML = LAB_DIR / "sample_data" / "bis_cbpol_sdmx_generic_sample.xml"

IMF_DATAMAPPER_URL = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA"
BIS_CBPOL_URL = "https://stats.bis.org/api/v1/data/WS_CBPOL/all/all"


@dataclass
class RateLimiter:
    """Very small rate limiter for beginner practice."""

    min_seconds_between_calls: float = 1.0
    last_call_time: float = 0.0

    def wait(self) -> None:
        """Pause so we do not send requests too quickly."""
        elapsed = time.monotonic() - self.last_call_time
        remaining = self.min_seconds_between_calls - elapsed
        if remaining > 0:
            time.sleep(remaining)
        self.last_call_time = time.monotonic()


def load_environment(env_file: str = ".env") -> None:
    env_path = LAB_DIR / env_file
    if env_path.exists():
        load_dotenv(env_path)


def build_headers(accept: str) -> dict[str, str]:
    """
    Build HTTP headers.

    IMF and BIS public examples do not require an API key for this lab, but
    many production APIs require a bearer token or subscription key. This
    function shows where that authentication header belongs.
    """
    headers = {
        "Accept": accept,
        "User-Agent": os.getenv("EXTERNAL_API_USER_AGENT", "Trainingcred-Module7-Lab/1.0"),
    }
    api_key = os.getenv("EXTERNAL_API_KEY")
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    return headers


def fetch_imf_weo_json(offline: bool = False) -> dict[str, Any]:
    """Fetch IMF DataMapper JSON, or use the local IMF sample."""
    if offline:
        return json.loads(SAMPLE_IMF_JSON.read_text(encoding="utf-8"))

    limiter = RateLimiter(float(os.getenv("API_MIN_SECONDS_BETWEEN_CALLS", "1.0")))
    limiter.wait()

    response = requests.get(
        IMF_DATAMAPPER_URL,
        params={"periods": "2024,2025,2026"},
        headers=build_headers("application/json"),
        timeout=20,
    )
    response.raise_for_status()
    return response.json()


def fetch_bis_cbpol_sdmx(offline: bool = False) -> str:
    """Fetch BIS CBPOL SDMX XML, or use the local BIS SDMX Generic sample."""
    if offline:
        return SAMPLE_BIS_XML.read_text(encoding="utf-8")

    limiter = RateLimiter(float(os.getenv("API_MIN_SECONDS_BETWEEN_CALLS", "1.0")))
    limiter.wait()

    response = requests.get(
        BIS_CBPOL_URL,
        params={"startPeriod": "2026-01", "endPeriod": "2026-03"},
        headers=build_headers("application/xml"),
        timeout=30,
    )
    response.raise_for_status()
    return response.text


def main() -> None:
    parser = argparse.ArgumentParser(description="Beginner REST API example.")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--offline", action="store_true", help="Use local samples instead of live API calls.")
    args = parser.parse_args()

    load_environment(args.env)

    imf_payload = fetch_imf_weo_json(offline=args.offline)
    bis_payload = fetch_bis_cbpol_sdmx(offline=args.offline)

    print("IMF JSON top-level keys:")
    print(list(imf_payload.keys()))
    print()
    print("First 500 characters of BIS SDMX XML:")
    print(bis_payload[:500])


if __name__ == "__main__":
    main()
