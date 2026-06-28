"""Macro outlook report built from WEO country and group indicators."""

from __future__ import annotations

from typing import Any

import pandas as pd
from sqlalchemy.engine import Engine

from database.weo_repository import extract_country_macro, extract_group_indicators
from reports.common import ReportArtifact, clean_records, format_number
from services.template_renderer import render_template


REPORT_ID = "macro_outlook"
TITLE = "Global Macro Outlook Executive Brief"
AUDIENCE = "Executive Committee and Monetary Policy"


def generate_report(engine: Engine | None, dataset: dict[str, Any], config: dict[str, Any], report_month: str) -> ReportArtifact:
    analysis_year = config["analysis"]["analysis_year"]
    trend_start = config["analysis"]["trend_start_year"]
    trend_end = config["analysis"]["trend_end_year"]
    trend_groups = config["weo_dataset"]["trend_groups"]

    macro_data, macro_source = extract_country_macro(engine, dataset["country_macro"], trend_start, trend_end)
    group_data, group_source = extract_group_indicators(engine, dataset["group_long"], trend_start, trend_end)
    data_source = group_source if group_source.startswith("T-SQL") else macro_source

    latest = macro_data.loc[macro_data["year"].eq(analysis_year)].copy()
    top_growth = latest.dropna(subset=["gdp_growth_pct"]).nlargest(10, "gdp_growth_pct")
    bottom_growth = latest.dropna(subset=["gdp_growth_pct"]).nsmallest(10, "gdp_growth_pct")

    group_latest = (
        group_data.loc[
            group_data["country"].isin(trend_groups)
            & group_data["indicator_id"].isin(["NGDP_RPCH", "PCPIPCH"])
            & group_data["year"].eq(analysis_year)
        ]
        .pivot_table(index="country", columns="indicator_id", values="value", aggfunc="first")
        .reset_index()
        .rename(columns={"NGDP_RPCH": "gdp_growth_pct", "PCPIPCH": "inflation_pct"})
    )

    growth_trend = group_data.loc[
        group_data["country"].isin(trend_groups)
        & group_data["indicator_id"].eq("NGDP_RPCH")
        & group_data["year"].between(trend_start, trend_end)
    ].copy()

    chart_years = list(range(trend_start, trend_end + 1))
    line_datasets = []
    for group_name in trend_groups:
        group_rows = growth_trend.loc[growth_trend["country"].eq(group_name)].set_index("year")
        line_datasets.append(
            {
                "label": group_name,
                "data": [round(float(group_rows.loc[year, "value"]), 2) if year in group_rows.index else None for year in chart_years],
            }
        )

    top_bottom_chart = {
        "labels": list(top_growth["country"]) + list(bottom_growth["country"]),
        "values": [round(float(value), 2) for value in list(top_growth["gdp_growth_pct"]) + list(bottom_growth["gdp_growth_pct"])],
    }

    world_growth = _lookup_group_value(group_latest, "World", "gdp_growth_pct")
    ssa_growth = _lookup_group_value(group_latest, "Sub-Saharan Africa (SSA)", "gdp_growth_pct")
    emerging_growth = _lookup_group_value(group_latest, "Emerging Market and Developing Economies", "gdp_growth_pct")

    summary_points = [
        f"World GDP growth is projected at {format_number(world_growth)}% in {analysis_year}.",
        f"Sub-Saharan Africa growth is projected at {format_number(ssa_growth)}%.",
        f"Emerging market and developing economies growth is projected at {format_number(emerging_growth)}%.",
    ]

    output_path = config["paths"]["html"] / f"weo_macro_outlook_{analysis_year}.html"
    render_template(
        config["paths"]["templates"],
        "reports/macro_outlook_report.html.j2",
        output_path,
        {
            "report_title": TITLE,
            "report_id": REPORT_ID,
            "audience": AUDIENCE,
            "central_bank_name": config["central_bank_name"],
            "report_month": report_month,
            "analysis_year": analysis_year,
            "data_source": data_source,
            "metadata": dataset["metadata"],
            "summary_points": summary_points,
            "group_rows": clean_records(group_latest.to_dict(orient="records")),
            "top_growth_rows": clean_records(top_growth[["country", "economic_group", "gdp_growth_pct"]].to_dict(orient="records")),
            "bottom_growth_rows": clean_records(bottom_growth[["country", "economic_group", "gdp_growth_pct"]].to_dict(orient="records")),
            "growth_line_chart": {"labels": chart_years, "datasets": line_datasets},
            "top_bottom_chart": top_bottom_chart,
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
            "country_rows": int(len(latest)),
            "trend_group_count": len(trend_groups),
        },
    )


def _lookup_group_value(frame: pd.DataFrame, group_name: str, column: str) -> float | None:
    row = frame.loc[frame["country"].eq(group_name)]
    if row.empty or pd.isna(row.iloc[0].get(column)):
        return None
    return float(row.iloc[0][column])
