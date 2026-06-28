"""Transform the WEO Excel workbook into analysis-ready DataFrames."""

from __future__ import annotations

from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


INDICATOR_LABELS = {
    "NGDP_RPCH": "gdp_growth_pct",
    "PCPIPCH": "inflation_pct",
    "LUR": "unemployment_rate",
    "BCA_NGDPD": "current_account_pct_gdp",
    "GGXWDG_NGDP": "government_debt_pct_gdp",
    "NGDPDPC": "gdp_per_capita_usd",
    "NID_NGDP": "investment_pct_gdp",
    "NGSD_NGDP": "savings_pct_gdp",
    "TX_RPCH": "export_volume_growth_pct",
    "TM_RPCH": "import_volume_growth_pct",
}


def standardize_column_names(frame: pd.DataFrame) -> pd.DataFrame:
    renamed_columns: dict[Any, Any] = {}
    for column in frame.columns:
        if isinstance(column, int):
            renamed_columns[column] = column
            continue

        clean_name = (
            str(column)
            .strip()
            .lower()
            .replace(".", "_")
            .replace(" ", "_")
            .replace("-", "_")
        )
        renamed_columns[column] = clean_name
    return frame.rename(columns=renamed_columns)


def get_year_columns(frame: pd.DataFrame) -> list[Any]:
    return [column for column in frame.columns if isinstance(column, int) or str(column).isdigit()]


def make_long_indicator_data(frame: pd.DataFrame, indicator_ids: list[str], source_sheet: str) -> pd.DataFrame:
    year_columns = get_year_columns(frame)
    id_columns = ["country_id", "country", "indicator_id", "indicator", "unit"]
    filtered = frame.loc[frame["indicator_id"].isin(indicator_ids), id_columns + year_columns].copy()

    long_df = filtered.melt(
        id_vars=id_columns,
        value_vars=year_columns,
        var_name="year",
        value_name="value",
    )
    long_df["year"] = long_df["year"].astype(int)
    long_df["value"] = pd.to_numeric(long_df["value"], errors="coerce")
    long_df["source_sheet"] = source_sheet
    return long_df.dropna(subset=["value"])


def make_country_macro_dataframe(countries: pd.DataFrame, group_composition: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    country_long = make_long_indicator_data(countries, list(INDICATOR_LABELS), "Countries")

    country_macro = (
        country_long.pivot_table(
            index=["country_id", "country", "year"],
            columns="indicator_id",
            values="value",
            aggfunc="first",
        )
        .reset_index()
        .rename(columns=INDICATOR_LABELS)
    )
    country_macro.columns.name = None

    advanced_codes = set(group_composition.loc[group_composition["group_name"].eq("Advanced Economies"), "country_id"])
    emerging_codes = set(group_composition.loc[group_composition["group_name"].eq("Emerging Market and Developing Economies"), "country_id"])
    ssa_codes = set(group_composition.loc[group_composition["group_name"].eq("Sub-Saharan Africa (SSA)"), "country_id"])

    country_macro["economic_group"] = np.select(
        [country_macro["country_id"].isin(advanced_codes), country_macro["country_id"].isin(emerging_codes)],
        ["Advanced Economies", "Emerging Market and Developing Economies"],
        default="Other",
    )
    country_macro["is_sub_saharan_africa"] = country_macro["country_id"].isin(ssa_codes).astype(int)
    return country_macro, country_long


def load_weo_dataset(workbook_path: Path) -> dict[str, Any]:
    """Load WEO sheets and return DataFrames used by the reports."""
    countries = standardize_column_names(pd.read_excel(workbook_path, sheet_name="Countries"))
    country_groups = standardize_column_names(pd.read_excel(workbook_path, sheet_name="Country Groups"))
    commodity_prices = standardize_column_names(pd.read_excel(workbook_path, sheet_name="Commodity Prices"))
    group_composition = standardize_column_names(pd.read_excel(workbook_path, sheet_name="Country Group Composition"))

    group_composition = group_composition.rename(
        columns={
            "groupcode": "group_code",
            "groupname": "group_name",
            "groupcode_previous": "group_code_previous",
            "countrycode": "country_id",
            "countryname": "country_name",
            "countrycode_previous": "country_code_previous",
        }
    )

    country_macro, country_long = make_country_macro_dataframe(countries, group_composition)
    group_long = make_long_indicator_data(country_groups, ["NGDP_RPCH", "PCPIPCH", "TM_RPCH", "TX_RPCH"], "Country Groups")
    commodity_long = make_long_indicator_data(
        commodity_prices,
        ["POILAPSP", "PFOODW", "PNGASW", "PCOALW", "PALLFNFW"],
        "Commodity Prices",
    )

    publication_dates = countries.get("publication_date", pd.Series(dtype="object")).dropna().astype(str)
    publication_date = publication_dates.max() if not publication_dates.empty else "unknown"
    loaded_at = pd.Timestamp.utcnow().isoformat()
    for frame in (country_macro, country_long, group_long, commodity_long):
        frame["source_publication_date"] = publication_date
        frame["source_workbook"] = str(workbook_path)
        frame["loaded_at"] = loaded_at

    return {
        "country_macro": country_macro,
        "country_long": country_long,
        "group_long": group_long,
        "commodity_long": commodity_long,
        "metadata": {
            "source_workbook": str(workbook_path),
            "publication_date": publication_date,
            "country_rows": int(len(country_macro)),
            "group_rows": int(len(group_long)),
            "commodity_rows": int(len(commodity_long)),
        },
    }
