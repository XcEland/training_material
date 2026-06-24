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
except Exception:  # pragma: no cover - depends on optional classroom package
    scrapy = None


if scrapy is not None:

    class MarketRatesSpider(scrapy.Spider):
        """Example spider structure for an authorised market-rates page."""

        name = "market_rates"
        allowed_domains = ["example.org"]
        start_urls = ["https://example.org/authorised-market-rates"]

        custom_settings = {
            # Be polite to source systems. Do not overload external websites.
            "DOWNLOAD_DELAY": 1.0,
            "ROBOTSTXT_OBEY": True,
        }

        def parse(self, response):
            for row in response.css("table#market-rates tbody tr"):
                cells = [text.strip() for text in row.css("td::text").getall()]
                if len(cells) != 4:
                    continue
                yield {
                    "RateDate": cells[0],
                    "CurrencyCode": cells[1],
                    "BuyRate": cells[2],
                    "SellRate": cells[3],
                }


def main() -> None:
    if scrapy is None:
        print("Scrapy is not installed. This is expected for the base setup.")
        print("For larger scraping projects, install it with: pip install scrapy")
        print("Then create a Scrapy project and move the spider class into spiders/market_rates.py")
    else:
        print("Scrapy is installed. This file defines MarketRatesSpider for study/reference.")


if __name__ == "__main__":
    main()
