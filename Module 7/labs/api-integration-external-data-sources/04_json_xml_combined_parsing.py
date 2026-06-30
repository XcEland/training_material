"""
JSON and XML/SDMX parsing lab.

External APIs often return nested JSON or XML. Relational databases need flat,
typed rows. This script maps IMF DataMapper JSON and BIS CBPOL SDMX XML into
table-shaped rows used by the Module 7 SQL schema.

Local files to inspect:
- sample_data/imf_datamapper_weo_inflation_sample.json
- sample_data/bis_cbpol_sdmx_generic_sample.xml

Postman URLs:
- IMF JSON:
  GET https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA?periods=2024,2025,2026
- BIS XML/SDMX:
  GET https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA?startPeriod=2024-01&endPeriod=2024-12&detail=full
"""

from __future__ import annotations

import json
import math
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

import pandas as pd


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_IMF_JSON = LAB_DIR / "sample_data" / "imf_datamapper_weo_inflation_sample.json"
SAMPLE_BIS_XML = LAB_DIR / "sample_data" / "bis_cbpol_sdmx_generic_sample.xml"

# These URLs can be pasted into Postman. Set the request method to GET.
# IMF may return HTTP 403 on some networks, so the lab keeps a local sample.
POSTMAN_IMF_URL = "https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA?periods=2024,2025,2026"
POSTMAN_BIS_URL = "https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA?startPeriod=2024-01&endPeriod=2024-12&detail=full"


def parse_imf_datamapper_json(payload: dict[str, Any], source_name: str = "IMF DataMapper API") -> list[dict[str, Any]]:
    """Parse IMF DataMapper-style JSON into relational observation rows."""
    values = payload.get("values", {})
    indicators = payload.get("indicators", {})
    countries = payload.get("countries", {})
    rows: list[dict[str, Any]] = []

    for indicator_code, countries_payload in values.items():
        indicator_info = indicators.get(indicator_code, {})
        for country_code, yearly_values in countries_payload.items():
            for year, value in yearly_values.items():
                rows.append(
                    {
                        "SourceName": source_name,
                        "CountryCode": country_code,
                        "CountryName": countries.get(country_code, country_code),
                        "IndicatorCode": indicator_code,
                        "IndicatorName": indicator_info.get("label", indicator_code),
                        "ObservationYear": year,
                        "ObservationValue": value,
                        "Unit": indicator_info.get("unit", "Unknown"),
                        "Frequency": "Annual",
                    }
                )
    return rows


def parse_bis_cbpol_sdmx(xml_text: str, source_name: str = "BIS CBPOL SDMX") -> list[dict[str, Any]]:
    """Parse BIS CBPOL SDMX Generic or structure-specific XML into policy-rate rows."""
    root = ET.fromstring(xml_text)
    if root.find(".//{*}SeriesKey") is not None:
        return _parse_bis_generic_sdmx(root, source_name)
    return _parse_bis_structure_specific_sdmx(root, source_name)


def _parse_bis_generic_sdmx(root: ET.Element, source_name: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for series in root.findall(".//{*}Series"):
        series_key = {
            item.attrib.get("id"): item.attrib.get("value")
            for item in series.findall("./{*}SeriesKey/{*}Value")
        }
        series_attributes = {
            item.attrib.get("id"): item.attrib.get("value")
            for item in series.findall("./{*}Attributes/{*}Value")
        }

        for obs in series.findall("./{*}Obs"):
            obs_dimension = obs.find("./{*}ObsDimension")
            obs_value = obs.find("./{*}ObsValue")
            obs_attributes = {
                item.attrib.get("id"): item.attrib.get("value")
                for item in obs.findall("./{*}Attributes/{*}Value")
            }
            rows.append(
                _policy_rate_row(
                    source_name=source_name,
                    frequency=series_key.get("FREQ"),
                    reference_area=series_key.get("REF_AREA"),
                    series_title=series_attributes.get("TITLE"),
                    observation_date=obs_dimension.attrib.get("value") if obs_dimension is not None else None,
                    policy_rate=obs_value.attrib.get("value") if obs_value is not None else None,
                    observation_status=obs_attributes.get("OBS_STATUS"),
                )
            )
    return rows


def _parse_bis_structure_specific_sdmx(root: ET.Element, source_name: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for series in root.findall(".//{*}Series"):
        for obs in series.findall("./{*}Obs"):
            rows.append(
                _policy_rate_row(
                    source_name=source_name,
                    frequency=series.attrib.get("FREQ"),
                    reference_area=series.attrib.get("REF_AREA"),
                    series_title=series.attrib.get("TITLE"),
                    observation_date=obs.attrib.get("TIME_PERIOD"),
                    policy_rate=obs.attrib.get("OBS_VALUE"),
                    observation_status=obs.attrib.get("OBS_STATUS"),
                )
            )
    return rows


def _policy_rate_row(
    source_name: str,
    frequency: str | None,
    reference_area: str | None,
    series_title: str | None,
    observation_date: str | None,
    policy_rate: Any,
    observation_status: str | None,
) -> dict[str, Any]:
    return {
        "SourceName": source_name,
        "Frequency": frequency,
        "ReferenceArea": reference_area,
        "SeriesTitle": series_title,
        "ObservationDate": observation_date,
        "PolicyRate": _to_float_or_none(policy_rate),
        "ObservationStatus": observation_status,
    }


def _to_float_or_none(value: Any) -> float | None:
    try:
        number = float(value)
    except Exception:
        return None
    return None if math.isnan(number) else number


def main() -> None:
    imf_payload = json.loads(SAMPLE_IMF_JSON.read_text(encoding="utf-8"))
    bis_payload = SAMPLE_BIS_XML.read_text(encoding="utf-8")

    imf_rows = parse_imf_datamapper_json(imf_payload)
    policy_rows = parse_bis_cbpol_sdmx(bis_payload)

    print("Local files used in this combined parser:")
    print(SAMPLE_IMF_JSON)
    print(SAMPLE_BIS_XML)
    print()
    print("Postman GET URLs:")
    print("IMF:", POSTMAN_IMF_URL)
    print("BIS:", POSTMAN_BIS_URL)
    print()
    print("IMF JSON rows mapped to relational shape:")
    print(pd.DataFrame(imf_rows).head(10))
    print()
    print("BIS SDMX XML rows mapped to relational shape:")
    print(pd.DataFrame(policy_rows).head(10))


if __name__ == "__main__":
    main()
