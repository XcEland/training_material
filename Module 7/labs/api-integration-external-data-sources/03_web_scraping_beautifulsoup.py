"""
BeautifulSoup web scraping fundamentals.

Important rule:
Only scrape sources you are authorised to use. For this lab, we scrape a
local HTML file that is explicitly provided as an authorised training source.
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd
from bs4 import BeautifulSoup


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_external_sources_sample.html"


def parse_authorised_sources_html(html_text: str, source_name: str = "Authorised Training HTML") -> list[dict[str, object]]:
    """Extract authorised external-source rows from the sample HTML table."""
    # Step 1: Parse raw HTML text into a searchable BeautifulSoup object.
    soup = BeautifulSoup(html_text, "html.parser")

    # Step 2: Select the one table that this lab is authorised to scrape.
    table = soup.select_one("table#external-data-sources")
    if table is None:
        raise ValueError("Could not find table#external-data-sources in HTML source")

    # Step 3: Loop over table body rows and extract cell text.
    rows: list[dict[str, object]] = []
    for table_row in table.select("tbody tr"):
        cells = [cell.get_text(strip=True) for cell in table_row.select("td")]
        if len(cells) != 5:
            continue
        source_title, source_type, owner, base_url, permission_status = cells

        # Step 4: Map each HTML row into the relational shape used by SQL.
        rows.append(
            {
                "SourceName": source_name,
                "ExternalSourceName": source_title,
                "SourceType": source_type,
                "OwnerName": owner,
                "BaseUrl": base_url,
                "PermissionStatus": permission_status,
            }
        )
    return rows


def parse_market_rates_html(html_text: str, source_name: str = "Authorised Training HTML") -> list[dict[str, object]]:
    """Backward-compatible wrapper for older tests and examples."""
    return parse_authorised_sources_html(html_text, source_name)


def main() -> None:
    html_text = SAMPLE_HTML.read_text(encoding="utf-8")
    rows = parse_authorised_sources_html(html_text)
    print("Scraped authorised external-source rows:")
    print(pd.DataFrame(rows))


if __name__ == "__main__":
    main()
