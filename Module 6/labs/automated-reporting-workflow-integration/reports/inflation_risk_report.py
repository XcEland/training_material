"""Inflation risk report built from WEO country indicators."""

from __future__ import annotations

from typing import Any

import pandas as pd
from sqlalchemy.engine import Engine

from database.weo_repository import extract_country_macro
from reports.common import ReportArtifact, clean_records, format_number
from reports.static_charts import chart_paths, save_bar_chart, save_scatter_chart
from services.template_renderer import render_template


REPORT_ID = "inflation_risk"
TITLE = "Inflation Risk Monitoring Report"
AUDIENCE = "Executive Committee, Monetary Policy, and Research"


def generate_report(engine: Engine | None, dataset: dict[str, Any], config: dict[str, Any], report_month: str) -> ReportArtifact:
    analysis_year = config["analysis"]["analysis_year"]
    start_year = analysis_year
    end_year = analysis_year
    threshold = config["analysis"]["high_inflation_threshold_pct"]

    macro_data, data_source = extract_country_macro(engine, dataset["country_macro"], start_year, end_year)
    latest = macro_data.loc[macro_data["year"].eq(analysis_year)].copy()
    latest = latest.dropna(subset=["inflation_pct", "gdp_growth_pct"])

    high_inflation = latest.loc[latest["inflation_pct"].ge(threshold)].sort_values("inflation_pct", ascending=False)
    top_inflation = latest.nlargest(15, "inflation_pct")

    bins = [-100, 0, 2, 5, 10, 20, 1000]
    labels = ["Below 0", "0 to 2", "2 to 5", "5 to 10", "10 to 20", "Above 20"]
    distribution = (
        pd.cut(latest["inflation_pct"], bins=bins, labels=labels)
        .value_counts(sort=False)
        .rename_axis("bucket")
        .reset_index(name="country_count")
    )
    distribution["bucket"] = distribution["bucket"].astype(str)

    scatter_rows = latest[["country", "economic_group", "inflation_pct", "gdp_growth_pct"]].copy()
    scatter_chart = {
        "datasets": [
            {
                "label": group_name,
                "data": [
                    {
                        "x": round(float(row["inflation_pct"]), 2),
                        "y": round(float(row["gdp_growth_pct"]), 2),
                        "country": row["country"],
                    }
                    for _, row in group_rows.iterrows()
                ],
            }
            for group_name, group_rows in scatter_rows.groupby("economic_group")
        ]
    }

    mean_inflation = float(latest["inflation_pct"].mean())
    median_inflation = float(latest["inflation_pct"].median())
    high_count = int(len(high_inflation))

    summary_points = [
        f"Average country inflation is {format_number(mean_inflation)}% in {analysis_year}.",
        f"Median country inflation is {format_number(median_inflation)}%.",
        f"{high_count} countries are at or above the {format_number(threshold)}% high-inflation monitoring threshold.",
    ]
    distribution_chart = {
        "labels": distribution["bucket"].tolist(),
        "values": distribution["country_count"].astype(int).tolist(),
    }
    distribution_path, distribution_image = chart_paths(config, "inflation_distribution.png")
    scatter_path, scatter_image = chart_paths(config, "inflation_vs_growth.png")
    save_bar_chart(
        distribution_chart["labels"],
        distribution_chart["values"],
        "Inflation Distribution",
        "Countries",
        distribution_path,
    )
    save_scatter_chart(
        scatter_chart["datasets"],
        "Inflation vs GDP Growth",
        "Inflation (%)",
        "GDP growth (%)",
        scatter_path,
    )

    output_path = config["paths"]["html"] / f"weo_inflation_risk_{analysis_year}.html"
    render_template(
        config["paths"]["templates"],
        "reports/inflation_risk_report.html.j2",
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
            "threshold": threshold,
            "mean_inflation": mean_inflation,
            "median_inflation": median_inflation,
            "high_count": high_count,
            "top_inflation_rows": clean_records(top_inflation[["country", "economic_group", "inflation_pct", "gdp_growth_pct"]].to_dict(orient="records")),
            "distribution_chart": distribution_chart,
            "scatter_chart": scatter_chart,
            "static_charts": {
                "distribution": distribution_image,
                "scatter": scatter_image,
            },
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
            "high_inflation_country_count": high_count,
            "mean_inflation_pct": round(mean_inflation, 2),
        },
    )
