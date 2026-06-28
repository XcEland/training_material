"""
Beginner lab: extracting one HTML table with BeautifulSoup.

Goal:
Turn one authorised HTML table into Python dictionaries. This is the core
web-scraping pattern learners need before seeing a reusable parser.
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd
from bs4 import BeautifulSoup


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_external_sources_sample.html"


def extract_table_headers(soup: BeautifulSoup) -> list[str]:
    """Get table header names from <th> cells."""
    return [
        header.get_text(strip=True)
        for header in soup.select("table#external-data-sources thead th")
    ]


def extract_table_rows(soup: BeautifulSoup) -> list[list[str]]:
    """Get table body values from <td> cells."""
    rows: list[list[str]] = []
    for table_row in soup.select("table#external-data-sources tbody tr"):
        cells = [cell.get_text(strip=True) for cell in table_row.select("td")]
        rows.append(cells)
    return rows


def table_to_dictionaries(headers: list[str], rows: list[list[str]]) -> list[dict[str, str]]:
    """Combine headers and row values into dictionaries."""
    dictionaries: list[dict[str, str]] = []
    for row in rows:
        if len(row) != len(headers):
            continue
        dictionaries.append(dict(zip(headers, row)))
    return dictionaries


def main() -> None:
    html_text = SAMPLE_HTML.read_text(encoding="utf-8")
    soup = BeautifulSoup(html_text, "html.parser")

    headers = extract_table_headers(soup)
    table_rows = extract_table_rows(soup)
    records = table_to_dictionaries(headers, table_rows)

    print("Extracted headers:")
    print(headers)
    print()
    print("Extracted records:")
    print(pd.DataFrame(records))


if __name__ == "__main__":
    main()
