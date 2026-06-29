# Module 7 Integration Test Plan

## Test Objectives

1. Confirm IMF JSON payloads map to relational WEO indicator rows.
2. Confirm BIS SDMX XML payloads map to relational policy-rate rows.
3. Confirm beginner JSON-only and XML-only scripts run before the combined parser.
4. Confirm beginner HTML loading and BeautifulSoup table extraction scripts run before the reusable parser.
5. Confirm beginner Scrapy concepts are introduced before the optional spider structure.
6. Confirm authorised HTML scraping extracts expected external source rows.
7. Confirm validation rejects incomplete or duplicate records.
8. Confirm the quality gate enforces completeness, validity, timeliness, and consistency.
9. Confirm a failed quality gate creates a rejection entry and alert artifact.
10. Confirm the pipeline can run end-to-end without internet access.
11. Confirm SQL Server loading is optional and does not block offline validation.

## Test Commands

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 7/labs/api-integration-external-data-sources"
pytest -q
```

## Manual Smoke Tests

```bash
python 01_beginner_requests_api.py --offline
python 02_json_only_imf_parsing.py
python 03_xml_only_bis_parsing.py
python 04_json_xml_combined_parsing.py
python 05_html_loading_basics.py
python 06_beautifulsoup_table_basics.py
python 07_web_scraping_beautifulsoup.py
python 08_scrapy_concepts_basics.py
python 09_optional_scrapy_spider.py
python 10_external_data_integration_pipeline.py --offline --skip-sql
```

## Acceptance Criteria

| Area | Acceptance criterion | Evidence |
| --- | --- | --- |
| REST API | Request code includes timeout, headers, status handling, and rate limiting | `01_beginner_requests_api.py` |
| JSON parsing | IMF nested indicator/country/year records become flat rows | pytest result |
| XML/SDMX parsing | BIS SDMX XML observations become flat policy-rate rows | pytest result |
| Teaching progression | Learners can run JSON-only and XML-only labs before the combined parser | manual smoke tests |
| HTML loading | Learners can load an authorised HTML file and inspect its title, heading, and row count | manual smoke tests |
| Table extraction | Learners can extract headers and rows before using the reusable scraper | manual smoke tests |
| Web scraping | Only authorised sample source registry is scraped | pytest result |
| Scrapy concepts | Learners can explain Spider, start URLs, Response, Item, and download delay | manual smoke tests |
| Validation | Invalid values and duplicates are rejected before SQL load | pytest result and quality output JSON |
| Quality gate | Dataset-level completeness, timeliness, and consistency checks run before SQL load | pytest result and `outputs/external_data_quality_alert.json` |
| Integration | Offline pipeline completes and writes output files | pytest result and `outputs/` files |

## Production Discussion

Before production use, teams must add:

- source-owner approval
- API key rotation policy
- retry and backoff policy
- monitoring and alerting
- schema drift detection
- database upsert strategy
- audit logging for raw payload retention
