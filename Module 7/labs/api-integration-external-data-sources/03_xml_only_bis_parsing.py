"""
Beginner lab: XML-only parsing with one data source.

Goal:
Read one BIS CBPOL SDMX Generic XML file and convert it into flat policy-rate
rows that match a relational database table.

Local sample file to open in VS Code:
sample_data/bis_cbpol_sdmx_generic_sample.xml

Postman/browser URL represented by this sample:
GET https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA?startPeriod=2024-01&endPeriod=2024-12&detail=full

This lab intentionally avoids JSON, web scraping, SQL loading, and validation.
It focuses only on the basic XML parsing pattern.
"""

from __future__ import annotations

import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

import pandas as pd


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_XML = LAB_DIR / "sample_data" / "bis_cbpol_sdmx_generic_sample.xml"

# Use this URL in Postman to see a live BIS CBPOL XML/SDMX response.
# Method: GET
# Headers: Accept: application/xml
POSTMAN_BIS_URL = "https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA?startPeriod=2024-01&endPeriod=2024-12&detail=full"

# Optional BIS bulk files for discussion or larger ingestion exercises:
# https://data.bis.org/static/bulk/WS_CBPOL_csv_flat.zip
# https://data.bis.org/static/bulk/WS_CBPOL_csv_col.zip
# https://data.bis.org/static/bulk/WS_CBPOL_sdmx-generic-2.1.zip


def load_xml_file(path: Path) -> ET.Element:
    """Load an XML file and return its root element."""
    xml_text = path.read_text(encoding="utf-8")
    return ET.fromstring(xml_text)


def child_values(parent: ET.Element, path: str) -> dict[str, str | None]:
    """
    Read SDMX <Value id="..." value="..."/> children into a dictionary.

    The {*} wildcard lets us ignore XML namespace prefixes such as generic:.
    This keeps the beginner code readable.
    """
    return {
        item.attrib.get("id"): item.attrib.get("value")
        for item in parent.findall(path)
    }


def parse_bis_policy_rate_xml(root: ET.Element) -> list[dict[str, Any]]:
    """Convert BIS SDMX Generic XML series and observations into flat rows."""
    rows: list[dict[str, Any]] = []

    for series in root.findall(".//{*}Series"):
        series_key = child_values(series, "./{*}SeriesKey/{*}Value")
        series_attributes = child_values(series, "./{*}Attributes/{*}Value")

        for observation in series.findall("./{*}Obs"):
            obs_dimension = observation.find("./{*}ObsDimension")
            obs_value = observation.find("./{*}ObsValue")
            obs_attributes = child_values(observation, "./{*}Attributes/{*}Value")

            rows.append(
                {
                    "SourceName": "BIS CBPOL SDMX Sample",
                    "Frequency": series_key.get("FREQ"),
                    "ReferenceArea": series_key.get("REF_AREA"),
                    "SeriesTitle": series_attributes.get("TITLE"),
                    "ObservationDate": obs_dimension.attrib.get("value") if obs_dimension is not None else None,
                    "PolicyRate": float(obs_value.attrib["value"]) if obs_value is not None else None,
                    "ObservationStatus": obs_attributes.get("OBS_STATUS"),
                }
            )
    return rows


def main() -> None:
    root = load_xml_file(SAMPLE_XML)
    rows = parse_bis_policy_rate_xml(root)
    frame = pd.DataFrame(rows)

    print("Local XML sample file:")
    print(SAMPLE_XML)
    print()
    print("Postman GET URL for the live BIS API:")
    print(POSTMAN_BIS_URL)
    print()
    print("XML-only parsing output:")
    print(frame)
    print()
    print("Relational columns:")
    print(list(frame.columns))


if __name__ == "__main__":
    main()
