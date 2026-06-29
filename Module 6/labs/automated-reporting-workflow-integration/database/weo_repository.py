"""SQL loading and T-SQL extraction functions for WEO reports."""

from __future__ import annotations

from typing import Any

import pandas as pd
from sqlalchemy import text
from sqlalchemy.engine import Engine


def ensure_weo_tables(engine: Engine) -> None:
    """Create the teaching tables if the setup script has not been run."""
    ddl = """
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm6')
    BEGIN
        EXEC('CREATE SCHEMA m6');
    END;

    IF OBJECT_ID('m6.WEOCountryMacro', 'U') IS NULL
    BEGIN
        CREATE TABLE m6.WEOCountryMacro (
            country_id VARCHAR(20) NOT NULL,
            country NVARCHAR(160) NOT NULL,
            year INT NOT NULL,
            gdp_growth_pct FLOAT NULL,
            inflation_pct FLOAT NULL,
            unemployment_rate FLOAT NULL,
            current_account_pct_gdp FLOAT NULL,
            government_debt_pct_gdp FLOAT NULL,
            gdp_per_capita_usd FLOAT NULL,
            investment_pct_gdp FLOAT NULL,
            savings_pct_gdp FLOAT NULL,
            export_volume_growth_pct FLOAT NULL,
            import_volume_growth_pct FLOAT NULL,
            economic_group NVARCHAR(120) NULL,
            is_sub_saharan_africa INT NOT NULL,
            source_publication_date VARCHAR(40) NULL,
            source_workbook NVARCHAR(500) NULL,
            loaded_at VARCHAR(40) NULL
        );
    END;

    IF OBJECT_ID('m6.WEOGroupIndicatorLong', 'U') IS NULL
    BEGIN
        CREATE TABLE m6.WEOGroupIndicatorLong (
            country_id VARCHAR(20) NOT NULL,
            country NVARCHAR(160) NOT NULL,
            indicator_id VARCHAR(40) NOT NULL,
            indicator NVARCHAR(500) NULL,
            unit NVARCHAR(80) NULL,
            year INT NOT NULL,
            value FLOAT NULL,
            source_sheet VARCHAR(60) NULL,
            source_publication_date VARCHAR(40) NULL,
            source_workbook NVARCHAR(500) NULL,
            loaded_at VARCHAR(40) NULL
        );
    END;

    IF OBJECT_ID('m6.WEOCommodityIndicatorLong', 'U') IS NULL
    BEGIN
        CREATE TABLE m6.WEOCommodityIndicatorLong (
            country_id VARCHAR(20) NOT NULL,
            country NVARCHAR(160) NOT NULL,
            indicator_id VARCHAR(40) NOT NULL,
            indicator NVARCHAR(500) NULL,
            unit NVARCHAR(80) NULL,
            year INT NOT NULL,
            value FLOAT NULL,
            source_sheet VARCHAR(60) NULL,
            source_publication_date VARCHAR(40) NULL,
            source_workbook NVARCHAR(500) NULL,
            loaded_at VARCHAR(40) NULL
        );
    END;
    """
    with engine.begin() as conn:
        conn.execute(text(ddl))


def load_weo_to_sql(engine: Engine | None, dataset: dict[str, Any]) -> str:
    if engine is None:
        return "SkippedSqlUnavailable"

    ensure_weo_tables(engine)
    tables = [
        ("WEOCountryMacro", dataset["country_macro"]),
        ("WEOGroupIndicatorLong", dataset["group_long"]),
        ("WEOCommodityIndicatorLong", dataset["commodity_long"]),
    ]

    with engine.begin() as conn:
        for table_name, frame in tables:
            conn.execute(text(f"DELETE FROM m6.{table_name};"))
            frame.to_sql(table_name, conn, schema="m6", if_exists="append", index=False, chunksize=500)
    return "LoadedToSql"


def extract_country_macro(engine: Engine | None, fallback: pd.DataFrame, start_year: int, end_year: int) -> tuple[pd.DataFrame, str]:
    query = """
    SELECT *
    FROM m6.WEOCountryMacro
    WHERE year BETWEEN :start_year AND :end_year;
    """
    return _read_sql_or_fallback(engine, query, fallback, {"start_year": start_year, "end_year": end_year}, "m6.WEOCountryMacro")


def extract_group_indicators(engine: Engine | None, fallback: pd.DataFrame, start_year: int, end_year: int) -> tuple[pd.DataFrame, str]:
    query = """
    SELECT *
    FROM m6.WEOGroupIndicatorLong
    WHERE year BETWEEN :start_year AND :end_year;
    """
    return _read_sql_or_fallback(engine, query, fallback, {"start_year": start_year, "end_year": end_year}, "m6.WEOGroupIndicatorLong")


def extract_commodity_indicators(engine: Engine | None, fallback: pd.DataFrame, start_year: int, end_year: int) -> tuple[pd.DataFrame, str]:
    query = """
    SELECT *
    FROM m6.WEOCommodityIndicatorLong
    WHERE year BETWEEN :start_year AND :end_year;
    """
    return _read_sql_or_fallback(engine, query, fallback, {"start_year": start_year, "end_year": end_year}, "m6.WEOCommodityIndicatorLong")


def _read_sql_or_fallback(
    engine: Engine | None,
    query: str,
    fallback: pd.DataFrame,
    params: dict[str, Any],
    source_name: str,
) -> tuple[pd.DataFrame, str]:
    filtered_fallback = fallback.loc[fallback["year"].between(params["start_year"], params["end_year"])].copy()
    if engine is None:
        return filtered_fallback, "Excel fallback"

    try:
        data = pd.read_sql(text(query), engine, params=params)
        if data.empty:
            raise ValueError(f"No rows found in {source_name}")
        return data, f"T-SQL from {source_name}"
    except Exception as exc:
        print(f"T-SQL extraction failed for {source_name}. Using Excel fallback:", exc)
        return filtered_fallback, "Excel fallback"
