# Automated Reporting and Workflow Integration

This Module 6 lab builds a monthly Central Bank reporting workflow using the same `WEOApr2026all.xlsx` workbook used in Modules 4 and 5.

The pipeline demonstrates:

- scheduled WEO workbook refresh or local workbook reuse
- SQL Server loading and T-SQL extraction when SQL Server is available
- Python processing with pandas
- multiple Jinja2-templated executive HTML reports
- interactive HTML charts with Chart.js
- stakeholder email preview or SMTP delivery
- JSONL run logging and Phase 2 benchmark evaluation

The workflow is safe for training. If SQL Server is unavailable, the reports use the WEO Excel workbook directly. Email delivery is dry-run by default.

## Learning Order

1. Review `scheduling_architecture_decision_log.md`.
2. Review `.env.example` and `config/reporting_config.json`.
3. Run the WEO report pack once.
4. Review generated reports in `outputs/html/`.
5. Review the stakeholder email preview in `outputs/email/`.
6. Review `outputs/phase2_pipeline_evaluation_YYYY-MM.json`.
7. Configure Windows Task Scheduler, cron, or the Python `schedule` demo.

## Project Structure

```text
automated-reporting-workflow-integration/
├── monthly_reporting_pipeline.py
├── scheduler_demo.py
├── 01_setup_monthly_reporting_dataset.sql
├── config/
│   ├── reporting_config.json
│   └── settings.py
├── database/
│   ├── connection.py
│   ├── weo_repository.py
│   └── weo_transform.py
├── reports/
│   ├── macro_outlook_report.py
│   ├── inflation_risk_report.py
│   └── commodity_monitoring_report.py
├── services/
│   ├── email_service.py
│   ├── pdf_service.py
│   ├── template_renderer.py
│   └── weo_downloader.py
├── templates/
│   ├── emails/
│   │   ├── executive_report_pack.txt.j2
│   │   ├── executive_report_pack.html.j2
│   │   └── operations_status.txt.j2
│   └── reports/
│       ├── base_report.html.j2
│       ├── macro_outlook_report.html.j2
│       ├── inflation_risk_report.html.j2
│       └── commodity_monitoring_report.html.j2
└── outputs/
    ├── data/
    ├── email/
    └── html/
```

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

Create a local environment file:

```bash
cd "Module 6/labs/automated-reporting-workflow-integration"
cp .env.example .env
```

Run the monthly report pack:

```bash
../../../.venv/bin/python monthly_reporting_pipeline.py --report-month 2026-06 --dry-run-email
```

Run only one report:

```bash
../../../.venv/bin/python monthly_reporting_pipeline.py --report-month 2026-06 --reports inflation_risk --dry-run-email
```

Use a different email template for operations monitoring:

```bash
../../../.venv/bin/python monthly_reporting_pipeline.py --report-month 2026-06 --email-template operations_status --dry-run-email
```

Email templates are configured in `config/reporting_config.json` under `email_templates`. Report order is configured in the same file with each report's `order` value.

Generate PDFs when WeasyPrint is installed on the machine:

```bash
../../../.venv/bin/python monthly_reporting_pipeline.py --report-month 2026-06 --generate-pdf --dry-run-email
```

If WeasyPrint is not installed, the pipeline still generates print-ready HTML reports and records `SkippedPdfDependencyMissing` in the metrics JSON.

## SQL Server Setup

If SQL Server is available, prepare the Module 6 tables:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 6/labs/automated-reporting-workflow-integration/01_setup_monthly_reporting_dataset.sql"
```

Then run the pipeline with SQL refresh:

```bash
../../../.venv/bin/python monthly_reporting_pipeline.py --report-month 2026-06 --refresh-data --dry-run-email
```

The report modules use T-SQL extraction from:

- `m6.WEOCountryMacro`
- `m6.WEOGroupIndicatorLong`
- `m6.WEOCommodityIndicatorLong`

## WEO Workbook Refresh

By default, the pipeline uses the existing Module 4 workbook:

```text
../../../Module 4/labs/python-data-manipulation-database-connectivity/data/WEOApr2026all.xlsx
```

To download a workbook during a scheduled run, set `WEO_DOWNLOAD_URL` in `.env`, then run:

```bash
../../../.venv/bin/python monthly_reporting_pipeline.py --download-weo --refresh-data --dry-run-email
```

The release manifest is written to:

```text
outputs/data/weo_release_manifest.json
```

## Expected Outputs

```text
outputs/html/weo_macro_outlook_2026.html
outputs/html/weo_inflation_risk_2026.html
outputs/html/weo_commodity_monitoring_2026.html
outputs/pdf/                       # optional when --generate-pdf is used
outputs/email/weo_executive_email_preview_2026-06.txt
outputs/email/weo_executive_email_preview_2026-06.html
outputs/weo_monthly_metrics_2026-06.json
outputs/phase2_pipeline_evaluation_2026-06.json
outputs/monthly_report_run_log.jsonl
```

## Scheduling

Use one of these guides:

- `windows_task_scheduler_setup.md`
- `cron_setup.md`
- `scheduler_demo.py`

The recommended production pattern is:

```text
Scheduler
  -> monthly_reporting_pipeline.py
      -> check/download WEO workbook
      -> transform and load SQL tables
      -> extract report datasets with T-SQL
      -> render Jinja2 HTML reports
      -> create email preview or send SMTP email
      -> write run logs and benchmark evaluation
```

## Exercise Deliverable

Submit:

- completed `scheduling_architecture_decision_log.md`
- generated WEO HTML reports from `outputs/html/`
- generated email preview or proof of SMTP delivery
- generated `phase2_pipeline_evaluation_YYYY-MM.json`
- completed `phase2_simulation_evaluation.md`
