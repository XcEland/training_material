# Module 7 Integration Test Plan

Use this plan during the 14:00 - 15:00 data lab and the 15:00 - 15:30 exercise.

## Test Objectives

1. Confirm JSON payloads map to relational rows.
2. Confirm XML payloads map to the same relational shape.
3. Confirm authorised HTML scraping extracts expected market-rate rows.
4. Confirm validation rejects incomplete or duplicate records.
5. Confirm the pipeline can run end-to-end without internet access.
6. Confirm SQL Server loading is optional and does not block offline validation.

## Test Commands

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 7/labs/api-integration-external-data-sources"
pytest -q
```

## Manual Smoke Tests

```bash
python 01_beginner_requests_api.py --offline
python 02_json_xml_parsing.py
python 03_web_scraping_beautifulsoup.py
python 04_optional_scrapy_spider.py
python 05_external_data_integration_pipeline.py --offline --skip-sql
```

## Acceptance Criteria

| Area | Acceptance criterion | Evidence |
| --- | --- | --- |
| REST API | Request code includes timeout, headers, status handling, and rate limiting | `01_beginner_requests_api.py` |
| JSON parsing | Nested records become flat rows | pytest result |
| XML parsing | Namespaced XML becomes flat rows | pytest result |
| Web scraping | Only authorised sample source is scraped | pytest result |
| Validation | Invalid values and duplicates are rejected before SQL load | pytest result and quality output JSON |
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
