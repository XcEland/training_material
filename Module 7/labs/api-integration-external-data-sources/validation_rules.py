"""
Data quality rules for Module 7 external data integration.

External data should never be inserted blindly. These rules create an
accept/reject decision before data reaches SQL Server.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import pandas as pd


@dataclass
class ValidationIssue:
    record_key: str
    severity: str
    rule_name: str
    message: str


def validate_api_observations(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Validate API observation rows and return accepted and rejected DataFrames."""
    issues: list[ValidationIssue] = []
    accepted: list[dict[str, Any]] = []
    seen_keys: set[tuple[str, str, str, int]] = set()

    for row in rows:
        record_key = f"{row.get('SourceName')}|{row.get('CountryCode')}|{row.get('IndicatorCode')}|{row.get('ObservationYear')}"
        row_issues: list[ValidationIssue] = []

        for field in ["SourceName", "CountryCode", "IndicatorCode", "ObservationYear", "ObservationValue"]:
            if row.get(field) in (None, ""):
                row_issues.append(ValidationIssue(record_key, "Error", f"Required_{field}", f"{field} is required"))

        try:
            year = int(row.get("ObservationYear"))
            if year < 1900 or year > 2100:
                row_issues.append(ValidationIssue(record_key, "Error", "YearRange", "ObservationYear must be between 1900 and 2100"))
        except Exception:
            row_issues.append(ValidationIssue(record_key, "Error", "YearType", "ObservationYear must be an integer"))

        try:
            value = float(row.get("ObservationValue"))
            if value < -100 or value > 1000:
                row_issues.append(ValidationIssue(record_key, "Warning", "ValueRange", "ObservationValue is outside expected training range"))
        except Exception:
            row_issues.append(ValidationIssue(record_key, "Error", "ValueType", "ObservationValue must be numeric"))

        business_key = (
            str(row.get("SourceName")),
            str(row.get("CountryCode")),
            str(row.get("IndicatorCode")),
            int(row.get("ObservationYear")) if str(row.get("ObservationYear")).isdigit() else -1,
        )
        if business_key in seen_keys:
            row_issues.append(ValidationIssue(record_key, "Error", "DuplicateBusinessKey", "Duplicate source/country/indicator/year"))

        if any(issue.severity == "Error" for issue in row_issues):
            issues.extend(row_issues)
            continue

        seen_keys.add(business_key)
        cleaned = row.copy()
        cleaned["ObservationYear"] = int(cleaned["ObservationYear"])
        cleaned["ObservationValue"] = float(cleaned["ObservationValue"])
        cleaned["QualityStatus"] = "AcceptedWithWarning" if row_issues else "Accepted"
        accepted.append(cleaned)
        issues.extend(row_issues)

    accepted_df = pd.DataFrame(accepted)
    rejected_df = pd.DataFrame([issue.__dict__ for issue in issues])
    return accepted_df, rejected_df


def validate_market_rates(rows: list[dict[str, Any]]) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Validate market-rate rows scraped from an authorised source."""
    issues: list[ValidationIssue] = []
    accepted: list[dict[str, Any]] = []

    for row in rows:
        record_key = f"{row.get('SourceName')}|{row.get('RateDate')}|{row.get('CurrencyCode')}"
        row_issues: list[ValidationIssue] = []

        for field in ["SourceName", "RateDate", "CurrencyCode", "BuyRate", "SellRate"]:
            if row.get(field) in (None, ""):
                row_issues.append(ValidationIssue(record_key, "Error", f"Required_{field}", f"{field} is required"))

        try:
            buy_rate = float(row.get("BuyRate"))
            sell_rate = float(row.get("SellRate"))
            if buy_rate <= 0 or sell_rate <= 0:
                row_issues.append(ValidationIssue(record_key, "Error", "PositiveRates", "Rates must be positive"))
            if sell_rate < buy_rate:
                row_issues.append(ValidationIssue(record_key, "Error", "RateOrder", "SellRate must be greater than or equal to BuyRate"))
        except Exception:
            row_issues.append(ValidationIssue(record_key, "Error", "RateType", "BuyRate and SellRate must be numeric"))

        if any(issue.severity == "Error" for issue in row_issues):
            issues.extend(row_issues)
            continue

        cleaned = row.copy()
        cleaned["CurrencyCode"] = str(cleaned["CurrencyCode"]).strip().upper()
        cleaned["BuyRate"] = float(cleaned["BuyRate"])
        cleaned["SellRate"] = float(cleaned["SellRate"])
        cleaned["QualityStatus"] = "AcceptedWithWarning" if row_issues else "Accepted"
        accepted.append(cleaned)
        issues.extend(row_issues)

    accepted_df = pd.DataFrame(accepted)
    rejected_df = pd.DataFrame([issue.__dict__ for issue in issues])
    return accepted_df, rejected_df
