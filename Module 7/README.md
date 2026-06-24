# Module 7: API Integration and External Data Sources

Module 7 extends the Central Bank data capability beyond internal databases. Students consume REST APIs, parse JSON and XML payloads, collect authorised web data, validate external data quality, and load accepted records into SQL Server.

## Lab

```text
Module 7/labs/api-integration-external-data-sources/
```

The lab covers:

- RESTful API consumption with `requests`
- authentication handling and rate limiting controls
- JSON and XML parsing into relational table-shaped rows
- BeautifulSoup web scraping from authorised sources
- Scrapy-style spider structure for larger scraping projects
- data source validation and quality assessment
- integration testing with pytest
- a final integration pipeline that loads accepted external data into SQL Server when available

The lab uses `TrainingDB` and creates objects under the `m7` schema when SQL Server is available. Python examples include local fallback payloads so students can run the exercises without internet or SQL Server.
