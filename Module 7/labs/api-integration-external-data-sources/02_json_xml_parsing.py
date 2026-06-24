"""
JSON and XML parsing lab.

External APIs often return nested JSON or XML. Relational databases need
flat, typed rows. This script maps both formats into the same relational
shape used by m7.ExternalApiObservations.
"""

from __future__ import annotations

import json
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

import pandas as pd


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_JSON = LAB_DIR / "sample_data" / "world_bank_indicator_sample.json"
SAMPLE_XML = LAB_DIR / "sample_data" / "world_bank_indicator_sample.xml"


def parse_world_bank_json(payload: list[Any], source_name: str = "World Bank API JSON") -> list[dict[str, Any]]:
    """Parse World Bank-style JSON into relational rows."""
    if not isinstance(payload, list) or len(payload) < 2:
        raise ValueError("Expected World Bank JSON payload format: [metadata, records]")

    records = payload[1]
    rows: list[dict[str, Any]] = []
    for record in records:
        rows.append(
            {
                "SourceName": source_name,
                "CountryCode": record.get("countryiso3code"),
                "CountryName": (record.get("country") or {}).get("value"),
                "IndicatorCode": (record.get("indicator") or {}).get("id"),
                "IndicatorName": (record.get("indicator") or {}).get("value"),
                "ObservationYear": record.get("date"),
                "ObservationValue": record.get("value"),
            }
        )
    return rows


def _text_or_none(element: ET.Element | None) -> str | None:
    if element is None or element.text is None:
        return None
    return element.text.strip()


def parse_world_bank_xml(xml_text: str, source_name: str = "World Bank API XML") -> list[dict[str, Any]]:
    """Parse World Bank-style XML into relational rows."""
    root = ET.fromstring(xml_text)
    namespace = {"wb": "http://www.worldbank.org"}
    rows: list[dict[str, Any]] = []

    for item in root.findall("wb:data", namespace):
        indicator = item.find("wb:indicator", namespace)
        country = item.find("wb:country", namespace)
        value_text = _text_or_none(item.find("wb:value", namespace))
        rows.append(
            {
                "SourceName": source_name,
                "CountryCode": _text_or_none(item.find("wb:countryiso3code", namespace)),
                "CountryName": _text_or_none(country),
                "IndicatorCode": indicator.attrib.get("id") if indicator is not None else None,
                "IndicatorName": _text_or_none(indicator),
                "ObservationYear": _text_or_none(item.find("wb:date", namespace)),
                "ObservationValue": float(value_text) if value_text else None,
            }
        )
    return rows


def main() -> None:
    json_payload = json.loads(SAMPLE_JSON.read_text(encoding="utf-8"))
    xml_payload = SAMPLE_XML.read_text(encoding="utf-8")

    json_rows = parse_world_bank_json(json_payload)
    xml_rows = parse_world_bank_xml(xml_payload)

    print("JSON rows mapped to relational shape:")
    print(pd.DataFrame(json_rows))
    print()
    print("XML rows mapped to relational shape:")
    print(pd.DataFrame(xml_rows))


if __name__ == "__main__":
    main()
