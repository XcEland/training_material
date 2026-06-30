"""
Check the Module 6 SQL Server tables created by the reporting pipeline.

Run from the Module 6 lab folder:
    ../../../.venv/bin/python 09_check_monthly_reporting_tables.py
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import text

from database.connection import build_sqlalchemy_engine


LAB_DIR = Path(__file__).resolve().parent


TABLES_TO_CHECK = [
    "WEOCountryMacro",
    "WEOGroupIndicatorLong",
    "WEOCommodityIndicatorLong",
    "MonthlyReportRunLog",
    "ReportDistributionAudit",
]


def print_frame(title: str, frame: pd.DataFrame) -> None:
    """Print one DataFrame section with a readable title."""

    print(f"\n{title}")
    print("-" * len(title))
    if frame.empty:
        print("No rows returned.")
    else:
        print(frame.to_string(index=False))


def main() -> None:
    load_dotenv(LAB_DIR / ".env")
    engine = build_sqlalchemy_engine()

    with engine.connect() as connection:
        table_status = pd.read_sql(
            text(
                """
                SELECT
                    s.name AS schema_name,
                    t.name AS table_name,
                    SUM(p.rows) AS row_count
                FROM sys.tables AS t
                INNER JOIN sys.schemas AS s
                    ON t.schema_id = s.schema_id
                LEFT JOIN sys.partitions AS p
                    ON t.object_id = p.object_id
                    AND p.index_id IN (0, 1)
                WHERE s.name = 'm6'
                GROUP BY s.name, t.name
                ORDER BY t.name;
                """
            ),
            connection,
        )
        print_frame("Module 6 table row counts", table_status)

        existing_tables = set(table_status["table_name"].tolist())
        missing_tables = [table for table in TABLES_TO_CHECK if table not in existing_tables]
        if missing_tables:
            print("\nMissing expected tables:")
            for table in missing_tables:
                print(f"- m6.{table}")

        if "WEOCountryMacro" in existing_tables:
            country_sample = pd.read_sql(
                text(
                    """
                    SELECT TOP (10)
                        country,
                        year,
                        gdp_growth_pct,
                        inflation_pct,
                        economic_group,
                        loaded_at
                    FROM m6.WEOCountryMacro
                    WHERE year = 2026
                    ORDER BY country;
                    """
                ),
                connection,
            )
            print_frame("Sample rows from m6.WEOCountryMacro", country_sample)

        if "WEOGroupIndicatorLong" in existing_tables:
            group_sample = pd.read_sql(
                text(
                    """
                    SELECT TOP (10)
                        country,
                        indicator_id,
                        indicator,
                        year,
                        value,
                        loaded_at
                    FROM m6.WEOGroupIndicatorLong
                    WHERE year = 2026
                    ORDER BY country, indicator_id;
                    """
                ),
                connection,
            )
            print_frame("Sample rows from m6.WEOGroupIndicatorLong", group_sample)

        if "WEOCommodityIndicatorLong" in existing_tables:
            commodity_sample = pd.read_sql(
                text(
                    """
                    SELECT TOP (10)
                        indicator_id,
                        indicator,
                        year,
                        value,
                        loaded_at
                    FROM m6.WEOCommodityIndicatorLong
                    WHERE year = 2026
                    ORDER BY indicator_id;
                    """
                ),
                connection,
            )
            print_frame("Sample rows from m6.WEOCommodityIndicatorLong", commodity_sample)


if __name__ == "__main__":
    main()
