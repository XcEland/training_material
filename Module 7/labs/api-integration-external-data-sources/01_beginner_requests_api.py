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
SAMPLE_JSON = LAB_DIR / "sample_data" / "world_bank_indicator_sample.json"
WORLD_BANK_URL = "https://api.worldbank.org/v2/country/LSO;ZAF;BWA/indicator/FP.CPI.TOTL.ZG"


@dataclass
class RateLimiter:
    """Very small rate limiter for beginner practice."""

    min_seconds_between_calls: float = 1.0
    last_call_time: float = 0.0

    def wait(self) -> None:
        elapsed = time.monotonic() - self.last_call_time
        remaining = self.min_seconds_between_calls - elapsed
        if remaining > 0:
            time.sleep(remaining)
        self.last_call_time = time.monotonic()


def load_environment(env_file: str = ".env") -> None:
    env_path = LAB_DIR / env_file
    if env_path.exists():
        load_dotenv(env_path)


def build_headers() -> dict[str, str]:
    """
    Build HTTP headers.

    The World Bank API used in this lab does not require an API key, but many
    production APIs require a bearer token or subscription key.
    """
    headers = {
        "Accept": "application/json",
        "User-Agent": os.getenv("EXTERNAL_API_USER_AGENT", "Trainingcred-Module7-Lab/1.0"),
    }
    api_key = os.getenv("EXTERNAL_API_KEY")
    if api_key:
        headers["Authorization"] = f"Bearer {api_key}"
    return headers


def fetch_world_bank_json(offline: bool = False) -> list[Any]:
    """Fetch JSON from the World Bank API or use local sample data."""
    if offline:
        return json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))

    limiter = RateLimiter(float(os.getenv("API_MIN_SECONDS_BETWEEN_CALLS", "1.0")))
    limiter.wait()

    response = requests.get(
        WORLD_BANK_URL,
        params={"format": "json", "per_page": 20},
        headers=build_headers(),
        timeout=20,
    )

    # Raise an exception for HTTP errors such as 401, 403, 404, or 500.
    response.raise_for_status()
    return response.json()


def main() -> None:
    parser = argparse.ArgumentParser(description="Beginner REST API example.")
    parser.add_argument("--env", default=".env")
    parser.add_argument("--offline", action="store_true", help="Use local sample JSON instead of the live API.")
    args = parser.parse_args()

    load_environment(args.env)
    payload = fetch_world_bank_json(offline=args.offline)
    metadata, records = payload

    print("API metadata:")
    print(json.dumps(metadata, indent=2))
    print()
    print(f"Records returned: {len(records)}")
    print("First record:")
    print(json.dumps(records[0], indent=2))


if __name__ == "__main__":
    main()
