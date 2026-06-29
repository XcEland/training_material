"""
Optional Scrapy-style spider example.

BeautifulSoup is enough for simple one-page extraction. Scrapy is better for
larger crawling projects because it provides spiders, pipelines, throttling,
retry behavior, and structured project layouts.

This file is safe to open even when Scrapy is not installed. It prints guidance
instead of failing at import time.
"""

from __future__ import annotations

try:
    import scrapy
except Exception:  # pragma: no cover - depends on optional Scrapy package
    scrapy = None


if scrapy is not None:

    class ExternalSourcesSpider(scrapy.Spider):
        """Example spider structure for an authorised external-source registry."""

        # The spider name is how Scrapy identifies this crawler.
        name = "external_sources"

        # allowed_domains prevents the spider from wandering to other domains.
        allowed_domains = ["example.org"]

        # start_urls are the first pages Scrapy would request.
        start_urls = ["https://example.org/authorised-external-sources"]

        custom_settings = {
            # Be polite to source systems. Do not overload external websites.
            "DOWNLOAD_DELAY": 1.0,
            "ROBOTSTXT_OBEY": True,
        }

        def parse(self, response):
            # Scrapy response.css() works like CSS selectors in BeautifulSoup.
            for row in response.css("table#external-data-sources tbody tr"):
                cells = [text.strip() for text in row.css("td::text").getall()]
                if len(cells) != 5:
                    continue

                # yield sends each extracted item into Scrapy's output pipeline.
                yield {
                    "ExternalSourceName": cells[0],
                    "SourceType": cells[1],
                    "OwnerName": cells[2],
                    "BaseUrl": cells[3],
                    "PermissionStatus": cells[4],
                }


def main() -> None:
    if scrapy is None:
        print("Scrapy is not installed. This is expected for the base setup.")
        print("For larger scraping projects, install it with: pip install scrapy")
        print("Then create a Scrapy project and move the spider class into spiders/external_sources.py")
    else:
        print("Scrapy is installed. This file defines ExternalSourcesSpider for study/reference.")


if __name__ == "__main__":
    main()
