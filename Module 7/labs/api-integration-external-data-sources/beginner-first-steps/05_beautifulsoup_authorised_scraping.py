"""
Step 5: Extract an authorised HTML table with BeautifulSoup.

The script starts with a small controlled HTML string. This keeps the focus on
HTML parsing before working with larger pages.
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd
from bs4 import BeautifulSoup


OUTPUT_DIR = Path(__file__).resolve().parent / "outputs"


html_text = """
<html>
<head>
    <title>Authorised External Sources</title>
</head>
<body>
    <h1>Approved Data Sources</h1>

    <table id="sources">
        <tr>
            <th>SourceName</th>
            <th>BaseUrl</th>
            <th>DataFormat</th>
            <th>PermissionStatus</th>
        </tr>
        <tr>
            <td>IMF DataMapper</td>
            <td>https://www.imf.org/external/datamapper/api</td>
            <td>JSON</td>
            <td>Approved</td>
        </tr>
        <tr>
            <td>BIS Statistics API</td>
            <td>https://stats.bis.org/api/v1</td>
            <td>XML</td>
            <td>Approved</td>
        </tr>
        <tr>
            <td>BIS Bulk Data</td>
            <td>https://data.bis.org/static/bulk/</td>
            <td>ZIP/CSV/XML</td>
            <td>Approved</td>
        </tr>
    </table>
</body>
</html>
"""


def scrape_authorised_sources(html: str) -> list[dict[str, str]]:
    soup = BeautifulSoup(html, "html.parser")
    table = soup.find("table", id="sources")
    if table is None:
        raise ValueError("Expected table id='sources' was not found.")

    rows: list[dict[str, str]] = []
    table_rows = table.find_all("tr")[1:]
    for table_row in table_rows:
        cells = table_row.find_all("td")
        rows.append(
            {
                "SourceName": cells[0].get_text(strip=True),
                "BaseUrl": cells[1].get_text(strip=True),
                "DataFormat": cells[2].get_text(strip=True),
                "PermissionStatus": cells[3].get_text(strip=True),
            }
        )
    return rows


def main() -> None:
    rows = scrape_authorised_sources(html_text)
    frame = pd.DataFrame(rows)

    OUTPUT_DIR.mkdir(exist_ok=True)
    output_path = OUTPUT_DIR / "05_authorised_sources.csv"
    frame.to_csv(output_path, index=False)

    print("Authorised sources extracted from HTML:")
    print(frame)
    print(f"\nSaved to {output_path}")


if __name__ == "__main__":
    main()
