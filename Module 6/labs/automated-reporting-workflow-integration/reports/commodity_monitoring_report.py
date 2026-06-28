"""Commodity monitoring report built from WEO commodity indicators."""

from __future__ import annotations

from typing import Any

import pandas as pd
from sqlalchemy.engine import Engine

from database.weo_repository import extract_commodity_indicators
from reports.common import ReportArtifact, clean_records, format_number
from services.template_renderer import render_template


REPORT_ID = "commodity_monitoring"
TITLE = "Commodity Price Monitoring Brief"
AUDIENCE = "Executive Committee, Markets, and Research"


def generate_report(engine: Engine | None, dataset: dict[str, Any], config: dict[str, Any], report_month: str) -> ReportArtifact:
    analysis_year = config["analysis"]["analysis_year"]
    prior_year = analysis_year - 1
    trend_start = config["analysis"]["trend_start_year"]
    trend_end = config["analysis"]["trend_end_year"]
    indicator_labels = config["weo_dataset"]["commodity_indicator_labels"]

    commodity_data, data_source = extract_commodity_indicators(engine, dataset["commodity_long"], trend_start, trend_end)
    commodity_data = commodity_data.loc[commodity_data["indicator_id"].isin(indicator_labels)].copy()

    latest = commodity_data.loc[commodity_data["year"].isin([prior_year, analysis_year])].copy()
    pivot = (
        latest.pivot_table(index=["indicator_id", "indicator"], columns="year", values="value", aggfunc="first")
        .reset_index()
        .rename(columns={prior_year: "prior_value", analysis_year: "current_value"})
    )
    pivot["display_name"] = pivot["indicator_id"].map(indicator_labels)
    pivot["change_pct"] = ((pivot["current_value"] - pivot["prior_value"]) / pivot["prior_value"]) * 100
    pivot = pivot.sort_values("display_name")

    chart_years = list(range(trend_start, trend_end + 1))
    line_datasets = []
    for indicator_id, display_name in indicator_labels.items():
        indicator_rows = commodity_data.loc[commodity_data["indicator_id"].eq(indicator_id)].set_index("year")
        line_datasets.append(
            {
                "label": display_name,
                "data": [round(float(indicator_rows.loc[year, "value"]), 2) if year in indicator_rows.index else None for year in chart_years],
            }
        )

    oil_row = pivot.loc[pivot["indicator_id"].eq("POILAPSP")]
    food_row = pivot.loc[pivot["indicator_id"].eq("PFOODW")]
    oil_change = _first_float(oil_row, "change_pct")
    food_change = _first_float(food_row, "change_pct")

    summary_points = [
        f"Oil price index movement from {prior_year} to {analysis_year}: {format_number(oil_change)}%.",
        f"Food price index movement from {prior_year} to {analysis_year}: {format_number(food_change)}%.",
        "Commodity trends are included because imported inflation and reserves management are sensitive to global price shocks.",
    ]

    output_path = config["paths"]["html"] / f"weo_commodity_monitoring_{analysis_year}.html"
    render_template(
        config["paths"]["templates"],
        "reports/commodity_monitoring_report.html.j2",
        output_path,
        {
            "report_title": TITLE,
            "report_id": REPORT_ID,
            "audience": AUDIENCE,
            "central_bank_name": config["central_bank_name"],
            "report_month": report_month,
            "analysis_year": analysis_year,
            "prior_year": prior_year,
            "data_source": data_source,
            "metadata": dataset["metadata"],
            "summary_points": summary_points,
            "commodity_rows": clean_records(pivot[["display_name", "current_value", "prior_value", "change_pct"]].to_dict(orient="records")),
            "commodity_line_chart": {"labels": chart_years, "datasets": line_datasets},
        },
    )

    return ReportArtifact(
        report_id=REPORT_ID,
        title=TITLE,
        audience=AUDIENCE,
        html_path=output_path,
        data_source=data_source,
        summary_points=summary_points,
        metrics={
            "analysis_year": analysis_year,
            "commodity_indicator_count": int(len(pivot)),
            "oil_change_pct": None if oil_change is None else round(oil_change, 2),
            "food_change_pct": None if food_change is None else round(food_change, 2),
        },
    )


def _first_float(frame: pd.DataFrame, column: str) -> float | None:
    if frame.empty or pd.isna(frame.iloc[0].get(column)):
        return None
    return float(frame.iloc[0][column])
