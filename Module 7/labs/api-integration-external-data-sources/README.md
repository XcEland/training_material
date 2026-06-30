# API Integration and External Data Sources

This Module 7 lab builds an external-data integration solution for Central Bank style analysis. The main datasets are:

- IMF DataMapper / WEO JSON for inflation and GDP growth indicators
- BIS CBPOL central bank policy-rate SDMX XML
- an authorised local HTML source registry for BeautifulSoup scraping practice

The pipeline validates all external rows before SQL Server insertion and writes offline output files for auditability.

## Discussion Outcomes

1. Implement RESTful API consumption scripts using Python `requests`, authentication handling, and rate limiting controls.
2. Develop JSON and XML/SDMX parsing routines that map external data structures to relational database schemas.
3. Apply BeautifulSoup web scraping techniques to extract structured data from authorised web sources.
4. Design validation and quality assessment procedures that enforce acceptance criteria before database insertion.
5. Construct integration testing suites that verify external data workflows end to end.
6. Execute an API integration exercise that delivers a validated, quality-assured external data load into SQL Server.

## Data Sources

| Source | Format | Module 7 use |
| --- | --- | --- |
| IMF DataMapper API | JSON REST API | WEO inflation and GDP growth observations |
| BIS CBPOL API | SDMX XML REST API | Central bank policy-rate observations |
| BIS CBPOL bulk files | CSV and SDMX XML ZIP files | Discussion of bulk ingestion and larger source files |
| Authorised local HTML | HTML table | BeautifulSoup scraping fundamentals |

The live IMF endpoint may block some corporate networks. The lab therefore includes local sample payloads so the exercise can be completed offline.

## Security and Rate Limits

API credentials must never be hard-coded in Python scripts. Store API keys and tokens in environment variables or a secrets management solution, then load them at runtime with `os.getenv()` or `os.environ.get()`.

Before building a production consumer, confirm:

- authentication mechanism: API key, OAuth 2.0, or mutual TLS
- allowed request rate and burst limits
- retry/backoff guidance
- consequences of exceeding limits, including IP blocking or service suspension

The teaching scripts use `EXTERNAL_API_KEY`, `EXTERNAL_API_USER_AGENT`, and `API_MIN_SECONDS_BETWEEN_CALLS` from `.env`.

## Quality Gate Principle

External data should never be loaded directly to a production database without passing a defined quality gate. Module 7 applies:

- completeness thresholds for required fields
- validity rules for ranges, dates, formats, and required values
- timeliness checks for IMF and BIS observations
- consistency checks across related fields
- rejection logs and `outputs/external_data_quality_alert.json` when a gate fails

If the quality gate fails, the pipeline skips SQL loading instead of silently inserting questionable data.

## Viewing JSON and XML Payloads

Open these files directly in VS Code before running the parsers:

```text
sample_data/imf_datamapper_weo_inflation_sample.json
sample_data/bis_cbpol_sdmx_generic_sample.xml
```

Use these GET URLs in Postman when internet access allows it:

```text
https://www.imf.org/external/datamapper/api/v2/PCPIPCH/LSO/ZAF/BWA/USA?periods=2024,2025,2026
https://stats.bis.org/api/v1/data/BIS,WS_CBPOL,1.0/M.ZA?startPeriod=2024-01&endPeriod=2024-12&detail=full
```

For Postman headers, use `Accept: application/json` for IMF and `Accept: application/xml` for BIS. IMF may return HTTP 403 on some corporate networks; use the local JSON sample in that case.

BIS policy-rate URLs use the dataflow `BIS,WS_CBPOL,1.0`. The frequency belongs in the series key:

```text
M.CA = monthly Canada
D.US = daily United States
M.JP = monthly Japan
M.ZA = monthly South Africa
```

## Learning Order

1. Run the SQL setup script when SQL Server is available.
2. Complete `beginner-first-steps/` to practise API GET requests, headers, JSON parsing, XML parsing, BeautifulSoup extraction, validation, and optional SQL loading one idea at a time.
3. Run `01_beginner_requests_api.py --offline` to learn API requests, headers, authentication placeholders, timeouts, and rate limiting in the main lab structure.
4. Run `02_json_only_imf_parsing.py` to learn JSON parsing from one source only.
5. Run `03_xml_only_bis_parsing.py` to learn XML/SDMX parsing from one source only.
6. Run `04_json_xml_combined_parsing.py` to combine IMF JSON and BIS SDMX XML into relational rows.
7. Run `05_html_loading_basics.py` to learn how to load and inspect an HTML page.
8. Run `06_beautifulsoup_table_basics.py` to extract one HTML table step by step.
9. Run `07_web_scraping_beautifulsoup.py` to use a reusable BeautifulSoup parser.
10. Run `08_scrapy_concepts_basics.py` to understand Scrapy terms before installing Scrapy.
11. Review `09_optional_scrapy_spider.py` for a Scrapy-style spider structure.
12. Run `10_external_data_integration_pipeline.py --offline --skip-sql` to validate and write accepted output files.
13. Run pytest integration tests.

## Files

```text
Module 7/labs/api-integration-external-data-sources/
├── README.md
├── 00_setup_external_data_schema.sql
├── beginner-first-steps/
│   ├── 01_basic_api_get.py
│   ├── 02_api_with_headers_auth_rate_limit.py
│   ├── 03_parse_imf_json.py
│   ├── 04_parse_bis_xml.py
│   ├── 05_beautifulsoup_authorised_scraping.py
│   ├── 06_validate_before_database.py
│   ├── 07_load_to_sql_server.py
│   ├── 08_full_pipeline_beginner.py
│   └── outputs/
├── 01_beginner_requests_api.py
├── 02_json_only_imf_parsing.py
├── 03_xml_only_bis_parsing.py
├── 04_json_xml_combined_parsing.py
├── 05_html_loading_basics.py
├── 06_beautifulsoup_table_basics.py
├── 07_web_scraping_beautifulsoup.py
├── 08_scrapy_concepts_basics.py
├── 09_optional_scrapy_spider.py
├── 10_external_data_integration_pipeline.py
├── db_utils.py
├── validation_rules.py
├── .env.example
├── .env.windows.example
├── integration_test_plan.md
├── sample_data/
│   ├── imf_datamapper_weo_inflation_sample.json
│   ├── bis_cbpol_sdmx_generic_sample.xml
│   ├── authorised_external_sources_sample.html
│   ├── world_bank_indicator_sample.json
│   ├── world_bank_indicator_sample.xml
│   └── authorised_market_rates_sample.html
├── tests/
│   └── test_external_integration.py
└── outputs/
```

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

If SQL Server is available:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 7/labs/api-integration-external-data-sources/00_setup_external_data_schema.sql"
```

Create a local environment file:

```bash
cd "Module 7/labs/api-integration-external-data-sources"
cp .env.example .env
```

## Run the Labs

Run the first-level scripts:

```bash
cd beginner-first-steps
python 01_basic_api_get.py
python 02_api_with_headers_auth_rate_limit.py
python 03_parse_imf_json.py
python 04_parse_bis_xml.py
python 05_beautifulsoup_authorised_scraping.py
python 06_validate_before_database.py
python 08_full_pipeline_beginner.py --offline
cd ..
```

Run the main Module 7 lab sequence:

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
pytest -q
```

To try live API calls:

```bash
python 01_beginner_requests_api.py
python 10_external_data_integration_pipeline.py --skip-sql
```

If a live API blocks the request, the final pipeline falls back to the local sample and records the accepted rows in `outputs/`.

## Windows Setup

```powershell
cd "$HOME\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt

sqlcmd -S localhost -E -C -i "Module 7\labs\api-integration-external-data-sources\00_setup_external_data_schema.sql"

cd "Module 7\labs\api-integration-external-data-sources"
copy .env.windows.example .env.windows
python 10_external_data_integration_pipeline.py --env .env.windows --offline
```

## SQL Tables

The setup script creates:

- `m7.ImfWeoIndicators`
- `m7.BisPolicyRates`
- `m7.AuthorisedWebSources`
- `m7.ExternalDataQualityLog`
- `m7.ExternalRawPayloads`
- `m7.ExternalIntegrationRunLog`

## Data Source Rules

Before inserting external data into SQL Server, the pipeline enforces these acceptance criteria:

- required source identifiers are present
- IMF country code, indicator code, year, and numeric value are present
- BIS frequency, reference area, observation date, and policy rate are present
- authorised web sources must show approved permission status
- duplicate business keys are removed
- quality status is recorded

## Expected Outputs

```text
outputs/accepted_imf_weo_observations.json
outputs/accepted_bis_policy_rates.json
outputs/accepted_authorised_sources.json
outputs/external_data_quality_issues.json
outputs/external_data_quality_alert.json
outputs/external_integration_run_summary.json
```

## Exercise Deliverable

Submit:

- output from the API script
- parsed IMF JSON and BIS XML rows
- scraped authorised-source rows
- validation summary
- SQL Server row count or offline output JSON
- completed integration test run
