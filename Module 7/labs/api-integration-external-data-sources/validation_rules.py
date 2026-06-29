"""
Data quality rules for Module 7 external data integration.

External data should never be inserted blindly. These rules create an
accept/reject decision before data reaches SQL Server.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import date
from typing import Any

import pandas as pd


@dataclass
class ValidationIssue:
    record_key: str
    severity: str
    rule_name: str
    message: str


def validate_imf_observations(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Validate IMF WEO observation rows and return accepted and rejected DataFrames."""
    issues: list[ValidationIssue] = []
    accepted: list[dict[str, Any]] = []
    seen_keys: set[tuple[str, str, str, int]] = set()

    for row in rows:
        record_key = f"{row.get('SourceName')}|{row.get('CountryCode')}|{row.get('IndicatorCode')}|{row.get('ObservationYear')}"
        row_issues: list[ValidationIssue] = []

        for field in ["SourceName", "CountryCode", "IndicatorCode", "ObservationYear", "ObservationValue"]:
            if row.get(field) in (None, ""):
                row_issues.append(ValidationIssue(record_key, "Error", f"Required_{field}", f"{field} is required"))

        year = _safe_int(row.get("ObservationYear"))
        if year is None:
            row_issues.append(ValidationIssue(record_key, "Error", "YearType", "ObservationYear must be an integer"))
        elif year < 1980 or year > 2100:
            row_issues.append(ValidationIssue(record_key, "Error", "YearRange", "ObservationYear must be between 1980 and 2100"))

        value = _safe_float(row.get("ObservationValue"))
        if value is None:
            row_issues.append(ValidationIssue(record_key, "Error", "ValueType", "ObservationValue must be numeric"))
        elif value < -100 or value > 1000:
            row_issues.append(ValidationIssue(record_key, "Warning", "ValueRange", "ObservationValue is outside expected WEO range"))

        business_key = (
            str(row.get("SourceName")),
            str(row.get("CountryCode")),
            str(row.get("IndicatorCode")),
            year if year is not None else -1,
        )
        if business_key in seen_keys:
            row_issues.append(ValidationIssue(record_key, "Error", "DuplicateBusinessKey", "Duplicate source/country/indicator/year"))

        if any(issue.severity == "Error" for issue in row_issues):
            issues.extend(row_issues)
            continue

        seen_keys.add(business_key)
        cleaned = row.copy()
        cleaned["ObservationYear"] = int(year)
        cleaned["ObservationValue"] = float(value)
        cleaned["QualityStatus"] = "AcceptedWithWarning" if row_issues else "Accepted"
        accepted.append(cleaned)
        issues.extend(row_issues)

    return pd.DataFrame(accepted), pd.DataFrame([issue.__dict__ for issue in issues])


def validate_policy_rates(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Validate BIS central bank policy-rate rows."""
    issues: list[ValidationIssue] = []
    accepted: list[dict[str, Any]] = []
    seen_keys: set[tuple[str, str, str, str]] = set()

    for row in rows:
        record_key = f"{row.get('SourceName')}|{row.get('Frequency')}|{row.get('ReferenceArea')}|{row.get('ObservationDate')}"
        row_issues: list[ValidationIssue] = []

        for field in ["SourceName", "Frequency", "ReferenceArea", "ObservationDate", "PolicyRate"]:
            if row.get(field) in (None, ""):
                row_issues.append(ValidationIssue(record_key, "Error", f"Required_{field}", f"{field} is required"))

        frequency = str(row.get("Frequency", "")).upper()
        if frequency not in {"D", "M"}:
            row_issues.append(ValidationIssue(record_key, "Error", "FrequencyAllowed", "Frequency must be D or M"))

        observation_date = _normalise_observation_date(row.get("ObservationDate"))
        if observation_date is None:
            row_issues.append(ValidationIssue(record_key, "Error", "DateType", "ObservationDate must be YYYY-MM or YYYY-MM-DD"))

        policy_rate = _safe_float(row.get("PolicyRate"))
        if policy_rate is None:
            row_issues.append(ValidationIssue(record_key, "Error", "RateType", "PolicyRate must be numeric"))
        elif policy_rate < -20 or policy_rate > 100:
            row_issues.append(ValidationIssue(record_key, "Warning", "RateRange", "PolicyRate is outside expected policy-rate range"))

        business_key = (
            str(row.get("SourceName")),
            frequency,
            str(row.get("ReferenceArea")),
            observation_date or "",
        )
        if business_key in seen_keys:
            row_issues.append(ValidationIssue(record_key, "Error", "DuplicateBusinessKey", "Duplicate source/frequency/area/date"))

        if any(issue.severity == "Error" for issue in row_issues):
            issues.extend(row_issues)
            continue

        seen_keys.add(business_key)
        cleaned = row.copy()
        cleaned["Frequency"] = frequency
        cleaned["ObservationDate"] = observation_date
        cleaned["PolicyRate"] = float(policy_rate)
        cleaned["QualityStatus"] = "AcceptedWithWarning" if row_issues else "Accepted"
        accepted.append(cleaned)
        issues.extend(row_issues)

    return pd.DataFrame(accepted), pd.DataFrame([issue.__dict__ for issue in issues])


def validate_authorised_sources(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Validate rows scraped from the authorised source-registry HTML."""
    issues: list[ValidationIssue] = []
    accepted: list[dict[str, Any]] = []

    for row in rows:
        record_key = f"{row.get('SourceName')}|{row.get('ExternalSourceName')}"
        row_issues: list[ValidationIssue] = []

        for field in ["SourceName", "ExternalSourceName", "SourceType", "OwnerName", "BaseUrl", "PermissionStatus"]:
            if row.get(field) in (None, ""):
                row_issues.append(ValidationIssue(record_key, "Error", f"Required_{field}", f"{field} is required"))

        permission = str(row.get("PermissionStatus", "")).lower()
        if "approved" not in permission:
            row_issues.append(ValidationIssue(record_key, "Error", "PermissionStatus", "Source must be approved before scraping"))

        if any(issue.severity == "Error" for issue in row_issues):
            issues.extend(row_issues)
            continue

        cleaned = row.copy()
        cleaned["QualityStatus"] = "Accepted"
        accepted.append(cleaned)

    return pd.DataFrame(accepted), pd.DataFrame([issue.__dict__ for issue in issues])


def validate_api_observations(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Backward-compatible name used by older examples."""
    return validate_imf_observations(rows)


def validate_market_rates(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Backward-compatible name used by older examples."""
    return validate_authorised_sources(rows)


def _safe_int(value: Any) -> int | None:
    try:
        return int(value)
    except Exception:
        return None


def _safe_float(value: Any) -> float | None:
    try:
        return float(value)
    except Exception:
        return None


def _normalise_observation_date(value: Any) -> str | None:
    text = str(value or "").strip()
    if len(text) == 7:
        text = f"{text}-01"
    try:
        return date.fromisoformat(text).isoformat()
    except Exception:
        return None
