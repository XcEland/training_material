"""Common report types and small formatting helpers."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class ReportArtifact:
    report_id: str
    title: str
    audience: str
    html_path: Path
    data_source: str
    summary_points: list[str]
    metrics: dict[str, Any]
    pdf_path: Path | None = None
    pdf_status: str = "NotRequested"


def format_number(value: float | int | None, digits: int = 1) -> str:
    if value is None:
        return "n/a"
    return f"{value:,.{digits}f}"


def clean_records(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Convert pandas/numpy values into template-friendly Python values."""
    cleaned: list[dict[str, Any]] = []
    for row in records:
        cleaned_row: dict[str, Any] = {}
        for key, value in row.items():
            if hasattr(value, "item"):
                value = value.item()
            cleaned_row[key] = None if value != value else value
        cleaned.append(cleaned_row)
    return cleaned
