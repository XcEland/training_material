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

1. Review `00_scheduling_architecture_decision_log.md`.
2. Review `.env.example` and `config/reporting_config.json`.
3. Run `02_windows_task_scheduler_smoke_test.py` once to confirm Python can write a scheduled-task log file.
4. Complete `jinja-beginner-step-by-step/` to learn one Jinja2 idea at a time.
5. Complete the `jinja-basics/` mini-lab before editing full report templates.
6. Complete `email-core-concepts/` to learn plain emails, attachments, and Jinja2 HTML emails.
7. Run the WEO report pack once.
8. Review generated reports in `outputs/html/`.
9. Review the stakeholder email preview in `outputs/email/`.
10. Review `outputs/phase2_pipeline_evaluation_YYYY-MM.json`.
11. Run `07_send_monthly_report_email_trigger.py --dry-run` to preview the single-recipient scheduled email lab.
12. Complete `cron-in-code-basics/` to see cron-like triggers around Python functions.
13. Configure Windows Task Scheduler, cron, or the Python `schedule` demo.

## Project Structure

```text
automated-reporting-workflow-integration/
├── 00_scheduling_architecture_decision_log.md
├── 01_setup_monthly_reporting_dataset.sql
├── 02_windows_task_scheduler_smoke_test.py
├── 03_windows_task_scheduler_setup.md
├── 04_cron_setup.md
├── 05_scheduler_demo.py
├── 06_monthly_reporting_pipeline.py
├── 07_send_monthly_report_email_trigger.py
├── 08_phase2_simulation_evaluation.md
├── 09_check_monthly_reporting_tables.py
├── jinja-beginner-step-by-step/
│   ├── 01_variables/
│   ├── 02_loops/
│   ├── 03_control_structures/
│   └── outputs/
├── jinja-basics/
│   ├── 01_render_jinja_basics.py
│   ├── templates/
│   └── outputs/
├── cron-in-code-basics/
│   ├── 01_function_interval_scheduler.py
│   ├── 02_function_daily_time_scheduler.py
│   ├── 03_cron_expression_function_scheduler.py
│   ├── 04_monthly_report_function_trigger.py
│   └── outputs/
├── email-core-concepts/
│   ├── 01_plain_message/
│   ├── 02_message_with_attachment/
│   ├── 03_jinja_html_email/
│   └── outputs/
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

Run the Jinja2 basics mini-lab:

```bash
../../../.venv/bin/python jinja-beginner-step-by-step/01_variables/render_variables.py
../../../.venv/bin/python jinja-beginner-step-by-step/02_loops/render_loops.py
../../../.venv/bin/python jinja-beginner-step-by-step/03_control_structures/render_control_structures.py
```

Then run the combined Jinja2 basics mini-lab:

```bash
../../../.venv/bin/python jinja-basics/01_render_jinja_basics.py
```

Open:

```text
jinja-basics/outputs/04_mini_macro_report.html
```

Run the beginner email basics mini-labs after confirming `REPORT_TO_EMAIL` and SMTP settings in `.env`:

```bash
../../../.venv/bin/python email-core-concepts/01_plain_message/send_plain_email.py
../../../.venv/bin/python email-core-concepts/02_message_with_attachment/send_email_with_attachment.py
../../../.venv/bin/python email-core-concepts/03_jinja_html_email/send_jinja_email.py
```

Run the safer `.env` preview pattern:

```bash
../../../.venv/bin/python email-core-concepts/04_env_preview_pattern/send_plain_email_env_preview.py
```

To actually send the Lesson 4 email to `REPORT_TO_EMAIL`, add `--send` after confirming SMTP settings in `.env`.

Run the monthly report pack:

```bash
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --report-month 2026-06 --dry-run-email
```

The pipeline generates HTML review copies and PDF distribution copies. Email
delivery attaches PDF reports when SMTP sending is enabled. HTML files remain in
`outputs/html/` so the reports can be opened in a browser.

Run only one report:

```bash
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --report-month 2026-06 --reports inflation_risk --dry-run-email
```

Use a different email template for operations monitoring:

```bash
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --report-month 2026-06 --email-template operations_status --dry-run-email
```

Email templates are configured in `config/reporting_config.json` under `email_templates`. Report order is configured in the same file with each report's `order` value.

Run the single-recipient triggered email lab in preview mode:

```bash
../../../.venv/bin/python 07_send_monthly_report_email_trigger.py --dry-run
```

Send the Jinja2 monthly reporting pack to `REPORT_TO_EMAIL` using SMTP settings from `.env`:

```bash
../../../.venv/bin/python 07_send_monthly_report_email_trigger.py
```

The trigger lab uses SQL Server when available and refreshes the reporting tables before rendering. If SQL Server is unavailable in the local environment, the existing pipeline falls back to the WEO workbook and records the data source in the metrics output.

Generate PDFs explicitly:

```bash
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --report-month 2026-06 --generate-pdf --dry-run-email
```

PDF generation uses WeasyPrint. If WeasyPrint is not installed, the pipeline
records `SkippedPdfDependencyMissing` in the metrics JSON. SMTP delivery requires
PDF attachments when PDF generation is enabled.

## SQL Server Setup

If SQL Server is available, prepare the Module 6 tables:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 6/labs/automated-reporting-workflow-integration/01_setup_monthly_reporting_dataset.sql"
```

Then run the pipeline with SQL refresh:

```bash
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --report-month 2026-06 --refresh-data --dry-run-email
```

The report modules use T-SQL extraction from:

- `m6.WEOCountryMacro`
- `m6.WEOGroupIndicatorLong`
- `m6.WEOCommodityIndicatorLong`

Check the SQL Server tables and sample records created by the pipeline:

```bash
../../../.venv/bin/python 09_check_monthly_reporting_tables.py
```

The check script prints row counts for the `m6` schema and sample rows from:

```text
m6.WEOCountryMacro
m6.WEOGroupIndicatorLong
m6.WEOCommodityIndicatorLong
```

## WEO Workbook Refresh

By default, the pipeline uses the existing Module 4 workbook:

```text
../../../Module 4/labs/python-data-manipulation-database-connectivity/data/WEOApr2026all.xlsx
```

To download a workbook during a scheduled run, set `WEO_DOWNLOAD_URL` in `.env`, then run:

```bash
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --download-weo --refresh-data --dry-run-email
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
outputs/pdf/weo_macro_outlook_2026.pdf
outputs/pdf/weo_inflation_risk_2026.pdf
outputs/pdf/weo_commodity_monitoring_2026.pdf
outputs/email/weo_executive_email_preview_2026-06.txt
outputs/email/weo_executive_email_preview_2026-06.html
outputs/weo_monthly_metrics_2026-06.json
outputs/phase2_pipeline_evaluation_2026-06.json
outputs/monthly_report_run_log.jsonl
outputs/monthly_report_stage_log.jsonl
```

`monthly_report_stage_log.jsonl` records progressive completed operations such
as workbook resolution, data transformation, database persistence, report
generation, PDF generation, email delivery, and metrics writing.

## Scheduling

Use one of these guides:

- `02_windows_task_scheduler_smoke_test.py`
- `03_windows_task_scheduler_setup.md`
- `04_cron_setup.md`
- `05_scheduler_demo.py`
- `07_send_monthly_report_email_trigger.py`
- `cron-in-code-basics/`

The recommended production pattern is:

```text
Scheduler
  -> 06_monthly_reporting_pipeline.py
      -> check/download WEO workbook
      -> transform and load SQL tables
      -> extract report datasets with T-SQL
      -> render Jinja2 HTML reports
      -> create email preview or send SMTP email
      -> write run logs and benchmark evaluation
```

## Exercise Deliverable

Submit:

- completed `00_scheduling_architecture_decision_log.md`
- generated WEO HTML reports from `outputs/html/`
- generated email preview or proof of SMTP delivery
- generated `phase2_pipeline_evaluation_YYYY-MM.json`
- completed `08_phase2_simulation_evaluation.md`
