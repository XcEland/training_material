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
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_market_rates_sample.html"


def parse_market_rates_html(html_text: str, source_name: str = "Authorised Training HTML") -> list[dict[str, object]]:
    """Extract market-rate rows from the authorised sample HTML table."""
    soup = BeautifulSoup(html_text, "html.parser")
    table = soup.select_one("table#market-rates")
    if table is None:
        raise ValueError("Could not find table#market-rates in HTML source")

    rows: list[dict[str, object]] = []
    for table_row in table.select("tbody tr"):
        cells = [cell.get_text(strip=True) for cell in table_row.select("td")]
        if len(cells) != 4:
            continue
        rate_date, currency_code, buy_rate, sell_rate = cells
        rows.append(
            {
                "SourceName": source_name,
                "RateDate": rate_date,
                "CurrencyCode": currency_code,
                "BuyRate": float(buy_rate),
                "SellRate": float(sell_rate),
            }
        )
    return rows


def main() -> None:
    html_text = SAMPLE_HTML.read_text(encoding="utf-8")
    rows = parse_market_rates_html(html_text)
    print("Scraped market-rate rows:")
    print(pd.DataFrame(rows))


if __name__ == "__main__":
    main()
