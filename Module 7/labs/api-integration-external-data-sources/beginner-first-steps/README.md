# Module 7 Beginner First Steps

This folder contains the first-level API integration scripts. Each file adds one
new idea before the full Module 7 pipeline.

## Order

```bash
python 01_basic_api_get.py
python 02_api_with_headers_auth_rate_limit.py
python 03_parse_imf_json.py
python 04_parse_bis_xml.py
python 05_beautifulsoup_authorised_scraping.py
python 06_validate_before_database.py
python 08_full_pipeline_beginner.py --offline
```

Run the SQL loading example only when SQL Server is ready and `.env` contains
the correct connection settings:

```bash
python 07_load_to_sql_server.py
python 08_full_pipeline_beginner.py --offline --load-sql
```

## Output Files

The scripts write practice outputs to:

```text
beginner-first-steps/outputs/
```

## Main Concepts

- `requests.get()` sends API requests.
- Headers tell an API what format is expected.
- JSON and XML must be parsed into rows before database loading.
- BeautifulSoup extracts structured values from authorised HTML.
- Validation separates accepted rows from rejected rows.
- SQL inserts use parameterized queries.
