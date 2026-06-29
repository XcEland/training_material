"""
Lab: loading and inspecting HTML.

Goal:
Before scraping data, inspect what HTML text looks like, how to load it, and
how BeautifulSoup helps find page elements.

This lab does not extract a full table yet. It only loads the authorised HTML
file and inspects simple page parts.
"""

from __future__ import annotations

from pathlib import Path

from bs4 import BeautifulSoup


LAB_DIR = Path(__file__).resolve().parent
SAMPLE_HTML = LAB_DIR / "sample_data" / "authorised_external_sources_sample.html"


def load_html_file(path: Path) -> str:
    """Read the HTML file as plain text."""
    return path.read_text(encoding="utf-8")


def inspect_html_page(html_text: str) -> dict[str, object]:
    """Use BeautifulSoup to inspect basic page elements."""
    soup = BeautifulSoup(html_text, "html.parser")

    # find() returns the first matching tag.
    title_tag = soup.find("title")
    heading_tag = soup.find("h1")

    # select() uses CSS selectors. Here we count the table rows in the body.
    table_rows = soup.select("table#external-data-sources tbody tr")

    return {
        "page_title": title_tag.get_text(strip=True) if title_tag else None,
        "main_heading": heading_tag.get_text(strip=True) if heading_tag else None,
        "table_row_count": len(table_rows),
    }


def main() -> None:
    html_text = load_html_file(SAMPLE_HTML)
    page_info = inspect_html_page(html_text)

    print("First 300 characters of the HTML file:")
    print(html_text[:300])
    print()
    print("Basic page inspection:")
    for key, value in page_info.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()
