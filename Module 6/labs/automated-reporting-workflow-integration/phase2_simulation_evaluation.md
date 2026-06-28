# Phase 2 Simulation Evaluation

Use this document after running `monthly_reporting_pipeline.py`.

## Pipeline Run Details

- Student/team:
- Report month:
- Run date:
- Scheduler approach selected:
- SQL Server used: Yes / No
- WEO workbook publication date:
- Email mode: Dry run / Sent

## Scheduling Reliability

| Benchmark | Evidence | Pass/Fail |
| --- | --- | --- |
| Start time is logged | `outputs/monthly_report_run_log.jsonl` |  |
| Completion time is logged | `outputs/monthly_report_run_log.jsonl` |  |
| Run status is logged | `outputs/monthly_report_run_log.jsonl` |  |
| WEO release check is logged | `outputs/data/weo_release_manifest.json` and metrics JSON |  |
| Failure behavior is documented | scheduling decision log |  |

## Output Quality

| Benchmark | Evidence | Pass/Fail |
| --- | --- | --- |
| Macro outlook report generated | `outputs/html/weo_macro_outlook_YYYY.html` |  |
| Inflation risk report generated | `outputs/html/weo_inflation_risk_YYYY.html` |  |
| Commodity monitoring report generated | `outputs/html/weo_commodity_monitoring_YYYY.html` |  |
| Reports include executive summaries and tables | HTML report summaries and tables |  |
| Reports include interactive charts | HTML Chart.js charts |  |
| Optional PDFs generated or skip status recorded | `outputs/weo_monthly_metrics_YYYY-MM.json` |  |
| Metrics JSON generated | `outputs/weo_monthly_metrics_YYYY-MM.json` |  |
| Phase 2 benchmark JSON generated | `outputs/phase2_pipeline_evaluation_YYYY-MM.json` |  |

## Stakeholder Communication

| Benchmark | Evidence | Pass/Fail |
| --- | --- | --- |
| Stakeholder groups configured | `config/reporting_config.json` |  |
| Email body generated | `outputs/email/weo_executive_email_preview_YYYY-MM.txt` or selected template preview |  |
| Report pack paths included | email preview |  |
| Delivery mode documented | run log and email preview |  |

## Overall Assessment

- Main strength of the pipeline:
- Main risk or gap:
- Change required before production deployment:
- Final pass/fail judgement:
