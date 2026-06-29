"""
Dataset-level quality gate for Module 7.

Row validation checks individual records. A quality gate checks whether the
accepted dataset as a whole is safe to load. Production pipelines should not
load external data silently when a quality gate fails.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Any

import pandas as pd


@dataclass
class GateIssue:
    source_name: str
    rule_name: str
    severity: str
    message: str


QUALITY_GATE_RULES = {
    "minimum_completeness_ratio": 0.95,
    "max_imf_observation_age_years": 5,
    "max_bis_observation_age_days": 366,
}


def run_quality_gate(
    accepted_imf: pd.DataFrame,
    accepted_policy: pd.DataFrame,
    accepted_sources: pd.DataFrame,
    today: date | None = None,
) -> tuple[bool, pd.DataFrame]:
    """
    Apply dataset-level gate checks before SQL loading.

    The checks are explicit and readable:
    - completeness: required columns should be at least 95% non-null
    - timeliness: IMF/BIS observations should not be too old
    - consistency: cross-field formats should still make sense after parsing
    """
    today = today or date.today()
    issues: list[GateIssue] = []

    issues.extend(
        _check_completeness(
            "IMF WEO observations",
            accepted_imf,
            ["SourceName", "CountryCode", "IndicatorCode", "ObservationYear", "ObservationValue"],
        )
    )
    issues.extend(
        _check_completeness(
            "BIS policy rates",
            accepted_policy,
            ["SourceName", "Frequency", "ReferenceArea", "ObservationDate", "PolicyRate"],
        )
    )
    issues.extend(
        _check_completeness(
            "Authorised web sources",
            accepted_sources,
            ["SourceName", "ExternalSourceName", "SourceType", "OwnerName", "BaseUrl", "PermissionStatus"],
        )
    )

    issues.extend(_check_imf_timeliness(accepted_imf, today))
    issues.extend(_check_bis_timeliness(accepted_policy, today))
    issues.extend(_check_consistency(accepted_imf, accepted_policy, accepted_sources))

    issue_frame = pd.DataFrame([issue.__dict__ for issue in issues])
    passed = issue_frame.empty or not issue_frame["severity"].eq("Error").any()
    return passed, issue_frame


def write_quality_alert(path: Path, gate_passed: bool, gate_issues: pd.DataFrame) -> None:
    """Write an alert artifact that operations staff can inspect."""
    path.parent.mkdir(exist_ok=True)
    payload = {
        "quality_gate_passed": gate_passed,
        "alert_required": not gate_passed,
        "issue_count": int(len(gate_issues)),
        "issues": gate_issues.to_dict(orient="records") if not gate_issues.empty else [],
    }
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def gate_issues_to_rejection_rows(gate_issues: pd.DataFrame) -> pd.DataFrame:
    """Map gate issues into the same shape used by the rejection log."""
    if gate_issues.empty:
        return pd.DataFrame(columns=["record_key", "severity", "rule_name", "message"])

    rows = []
    for _, issue in gate_issues.iterrows():
        rows.append(
            {
                "record_key": f"QUALITY_GATE|{issue['source_name']}|{issue['rule_name']}",
                "severity": issue["severity"],
                "rule_name": issue["rule_name"],
                "message": issue["message"],
            }
        )
    return pd.DataFrame(rows)


def _check_completeness(source_name: str, frame: pd.DataFrame, required_columns: list[str]) -> list[GateIssue]:
    issues: list[GateIssue] = []
    if frame.empty:
        return [GateIssue(source_name, "CompletenessRows", "Error", "No accepted rows are available.")]

    threshold = QUALITY_GATE_RULES["minimum_completeness_ratio"]
    for column in required_columns:
        if column not in frame.columns:
            issues.append(GateIssue(source_name, "CompletenessColumn", "Error", f"Missing required column: {column}"))
            continue

        completeness_ratio = frame[column].notna().mean()
        if completeness_ratio < threshold:
            issues.append(
                GateIssue(
                    source_name,
                    "CompletenessRatio",
                    "Error",
                    f"{column} completeness is {completeness_ratio:.1%}; required minimum is {threshold:.1%}.",
                )
            )
    return issues


def _check_imf_timeliness(frame: pd.DataFrame, today: date) -> list[GateIssue]:
    if frame.empty or "ObservationYear" not in frame.columns:
        return []

    newest_year = int(frame["ObservationYear"].max())
    oldest_allowed_year = today.year - QUALITY_GATE_RULES["max_imf_observation_age_years"]
    if newest_year < oldest_allowed_year:
        return [
            GateIssue(
                "IMF WEO observations",
                "Timeliness",
                "Error",
                f"Newest IMF observation year is {newest_year}; expected at least {oldest_allowed_year}.",
            )
        ]
    return []


def _check_bis_timeliness(frame: pd.DataFrame, today: date) -> list[GateIssue]:
    if frame.empty or "ObservationDate" not in frame.columns:
        return []

    newest_date = pd.to_datetime(frame["ObservationDate"], errors="coerce").max()
    if pd.isna(newest_date):
        return [GateIssue("BIS policy rates", "Timeliness", "Error", "No valid BIS observation dates were parsed.")]

    age_days = (pd.Timestamp(today) - newest_date).days
    if age_days > QUALITY_GATE_RULES["max_bis_observation_age_days"]:
        return [
            GateIssue(
                "BIS policy rates",
                "Timeliness",
                "Error",
                f"Newest BIS observation is {age_days} days old; allowed maximum is {QUALITY_GATE_RULES['max_bis_observation_age_days']} days.",
            )
        ]
    return []


def _check_consistency(
    accepted_imf: pd.DataFrame,
    accepted_policy: pd.DataFrame,
    accepted_sources: pd.DataFrame,
) -> list[GateIssue]:
    issues: list[GateIssue] = []

    if not accepted_imf.empty and "Frequency" in accepted_imf.columns:
        bad_frequency_rows = accepted_imf.loc[~accepted_imf["Frequency"].eq("Annual")]
        if not bad_frequency_rows.empty:
            issues.append(GateIssue("IMF WEO observations", "ConsistencyFrequency", "Error", "IMF WEO rows should be annual."))

    if not accepted_policy.empty and {"Frequency", "ObservationDate"}.issubset(accepted_policy.columns):
        dates = pd.to_datetime(accepted_policy["ObservationDate"], errors="coerce")
        monthly_rows = accepted_policy.loc[accepted_policy["Frequency"].eq("M")]
        monthly_dates = dates.loc[monthly_rows.index]
        if not monthly_dates.empty and not monthly_dates.dt.day.eq(1).all():
            issues.append(GateIssue("BIS policy rates", "ConsistencyMonthlyDate", "Error", "Monthly BIS rows should use first day of month."))

    if not accepted_sources.empty and "BaseUrl" in accepted_sources.columns:
        invalid_urls = accepted_sources.loc[~accepted_sources["BaseUrl"].astype(str).str.startswith(("http://", "https://"))]
        if not invalid_urls.empty:
            issues.append(GateIssue("Authorised web sources", "ConsistencyUrl", "Error", "Source URLs must start with http:// or https://."))

    return issues
