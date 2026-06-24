# API Integration and External Data Sources

This Module 7 lab teaches external data ingestion from beginner to advanced level. The examples use public financial/economic style data, local sample payloads, validation rules, and optional SQL Server loading.

The lab is designed to run reliably:

- Real API calls are supported.
- Local JSON/XML/HTML samples are included for offline practice.
- SQL Server inserts are attempted only when a connection is available.
- Tests use local samples and do not require internet access.

## Learning Order

1. Run the SQL setup script when SQL Server is available.
2. Start with `01_beginner_requests_api.py` to understand basic API calls, authentication headers, and rate limiting.
3. Run `02_json_xml_parsing.py` to map external JSON/XML payloads into relational rows.
4. Run `03_web_scraping_beautifulsoup.py` to extract structured data from an authorised local HTML source.
5. Review `04_optional_scrapy_spider.py` for a Scrapy-style spider structure.
6. Run `05_external_data_integration_pipeline.py` to validate and load accepted external records.
7. Run pytest integration tests.

## Files

```text
Module 7/labs/api-integration-external-data-sources/
├── README.md
├── 01_setup_external_data_schema.sql
├── 01_beginner_requests_api.py
├── 02_json_xml_parsing.py
├── 03_web_scraping_beautifulsoup.py
├── 04_optional_scrapy_spider.py
├── 05_external_data_integration_pipeline.py
├── db_utils.py
├── validation_rules.py
├── .env.example
├── .env.windows.example
├── integration_test_plan.md
├── sample_data/
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
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 7/labs/api-integration-external-data-sources/01_setup_external_data_schema.sql"
```

Create a local environment file:

```bash
cd "Module 7/labs/api-integration-external-data-sources"
cp .env.example .env
```

## Run the Labs

```bash
python 01_beginner_requests_api.py --offline
python 02_json_xml_parsing.py
python 03_web_scraping_beautifulsoup.py
python 05_external_data_integration_pipeline.py --offline --skip-sql
pytest -q
```

To try a live API call:

```bash
python 01_beginner_requests_api.py
python 05_external_data_integration_pipeline.py
```

## Windows Setup

```powershell
cd "$HOME\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt

sqlcmd -S localhost -E -C -i "Module 7\labs\api-integration-external-data-sources\01_setup_external_data_schema.sql"

cd "Module 7\labs\api-integration-external-data-sources"
copy .env.windows.example .env.windows
python 05_external_data_integration_pipeline.py --env .env.windows --offline
```

## Data Source Rules

Before inserting external data into SQL Server, the pipeline enforces these acceptance criteria:

- source name is present
- country code is present
- indicator code is present
- observation year is valid
- numeric value is present
- duplicate business keys are removed
- quality status is recorded

## Exercise Deliverable

Submit:

- output from the API script
- parsed JSON/XML rows
- scraped market-rate rows
- validation summary
- SQL Server row count or offline output JSON
- completed integration test run
