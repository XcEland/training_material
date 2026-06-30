"""
Step 4: Parse BIS SDMX XML into flat database-friendly rows.

The XML contains Series elements and Obs elements. Each observation becomes one
row that can later be validated and inserted into SQL Server.
"""

from __future__ import annotations

from pathlib import Path
import xml.etree.ElementTree as ET

import pandas as pd
import requests


LAB_DIR = Path(__file__).resolve().parents[1]
OUTPUT_DIR = Path(__file__).resolve().parent / "outputs"
SAMPLE_XML = LAB_DIR / "sample_data" / "bis_cbpol_sdmx_generic_sample.xml"
BIS_URL = "https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA"


def fetch_bis_xml() -> str:
    try:
        response = requests.get(
            BIS_URL,
            params={"startPeriod": "2024-01", "endPeriod": "2024-12", "detail": "full"},
            headers={"Accept": "application/xml"},
            timeout=30,
        )
        response.raise_for_status()
        return response.text
    except Exception as exc:
        print(f"Live BIS request did not complete: {exc}")
        print(f"Using local sample file: {SAMPLE_XML}")
        return SAMPLE_XML.read_text(encoding="utf-8")


def get_value_children(parent: ET.Element, path: str) -> dict[str, str | None]:
    values: dict[str, str | None] = {}
    for item in parent.findall(path):
        key = item.attrib.get("id")
        value = item.attrib.get("value")
        if key:
            values[key] = value
    return values


def parse_bis_xml(xml_text: str) -> list[dict[str, object]]:
    root = ET.fromstring(xml_text)
    if root.find(".//{*}SeriesKey") is None:
        return parse_structure_specific_bis_xml(root)

    rows: list[dict[str, object]] = []

    for series in root.findall(".//{*}Series"):
        series_key = get_value_children(series, "./{*}SeriesKey/{*}Value")
        series_attributes = get_value_children(series, "./{*}Attributes/{*}Value")

        for obs in series.findall("./{*}Obs"):
            obs_dimension = obs.find("./{*}ObsDimension")
            obs_value = obs.find("./{*}ObsValue")
            obs_attributes = get_value_children(obs, "./{*}Attributes/{*}Value")

            policy_rate = None
            if obs_value is not None and obs_value.attrib.get("value") is not None:
                policy_rate = float(obs_value.attrib["value"])

            rows.append(
                {
                    "SourceName": "BIS CBPOL",
                    "Frequency": series_key.get("FREQ"),
                    "ReferenceArea": series_key.get("REF_AREA"),
                    "SeriesTitle": series_attributes.get("TITLE"),
                    "ObservationDate": obs_dimension.attrib.get("value") if obs_dimension is not None else None,
                    "PolicyRate": policy_rate,
                    "ObservationStatus": obs_attributes.get("OBS_STATUS"),
                }
            )
    return rows


def parse_structure_specific_bis_xml(root: ET.Element) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for series in root.findall(".//{*}Series"):
        for obs in series.findall("./{*}Obs"):
            policy_rate = None
            if obs.attrib.get("OBS_VALUE") is not None:
                policy_rate = float(obs.attrib["OBS_VALUE"])

            rows.append(
                {
                    "SourceName": "BIS CBPOL",
                    "Frequency": series.attrib.get("FREQ"),
                    "ReferenceArea": series.attrib.get("REF_AREA"),
                    "SeriesTitle": series.attrib.get("TITLE"),
                    "ObservationDate": obs.attrib.get("TIME_PERIOD"),
                    "PolicyRate": policy_rate,
                    "ObservationStatus": obs.attrib.get("OBS_STATUS"),
                }
            )
    return rows


def main() -> None:
    xml_text = fetch_bis_xml()
    rows = parse_bis_xml(xml_text)
    if not rows or all(row.get("PolicyRate") is None for row in rows):
        print("Live BIS XML shape differs from the teaching sample.")
        print(f"Using local sample file: {SAMPLE_XML}")
        rows = parse_bis_xml(SAMPLE_XML.read_text(encoding="utf-8"))

    frame = pd.DataFrame(rows)

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "04_bis_policy_rate_rows.csv"
    frame.to_csv(output_path, index=False)

    print("Parsed BIS policy rate rows:")
    print(frame)
    print(f"\nSaved to {output_path}")


if __name__ == "__main__":
    main()
