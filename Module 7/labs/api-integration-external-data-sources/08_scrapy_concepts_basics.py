"""
Lab: Scrapy concepts without requiring Scrapy to be installed.

Goal:
Understand what Scrapy adds beyond BeautifulSoup before reviewing the optional
spider file.

BeautifulSoup pattern:
1. Load one HTML page.
2. Parse it.
3. Extract rows.

Scrapy pattern:
1. A Spider defines where to start.
2. Scrapy sends Requests to those URLs.
3. Scrapy passes each Response into parse().
4. parse() yields dictionaries or more Requests.

This file uses the same authorised local HTML sample and plain BeautifulSoup
so it runs in the base environment. It prints the Scrapy-style concepts and
then demonstrates what a spider's parse method would yield.
"""

from __future__ import annotations

from pathlib import Path

from bs4 import BeautifulSoup


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_external_sources_sample.html"


SCRAPY_CONCEPTS = {
    "Spider": "A class that contains the crawl rules and parse logic.",
    "start_urls": "The first URLs Scrapy should request.",
    "Response": "The downloaded page passed into the spider's parse method.",
    "Item": "A dictionary-like record yielded by parse().",
    "DOWNLOAD_DELAY": "A polite delay between requests so the source is not overloaded.",
}


def explain_scrapy_concepts() -> list[tuple[str, str]]:
    """Return Scrapy terms in a clear order."""
    return list(SCRAPY_CONCEPTS.items())


def simulate_spider_parse(html_text: str) -> list[dict[str, str]]:
    """
    Simulate the records a Scrapy parse() method would yield.

    Real Scrapy code receives a Response object and can use response.css().
    This bridge uses BeautifulSoup so the file can run without installing
    Scrapy.
    """
    soup = BeautifulSoup(html_text, "html.parser")
    items: list[dict[str, str]] = []

    # This selector matches the same authorised source table used earlier.
    for row in soup.select("table#external-data-sources tbody tr"):
        cells = [cell.get_text(strip=True) for cell in row.select("td")]
        if len(cells) != 5:
            continue

        # Each dictionary below is similar to what a Scrapy spider would yield.
        items.append(
            {
                "ExternalSourceName": cells[0],
                "SourceType": cells[1],
                "OwnerName": cells[2],
                "BaseUrl": cells[3],
                "PermissionStatus": cells[4],
            }
        )
    return items


def main() -> None:
    print("Scrapy concepts:")
    for term, explanation in explain_scrapy_concepts():
        print(f"- {term}: {explanation}")

    print()
    print("Simulated Scrapy parse() output from the authorised local HTML file:")
    html_text = SAMPLE_HTML.read_text(encoding="utf-8")
    for item in simulate_spider_parse(html_text):
        print(item)


if __name__ == "__main__":
    main()
