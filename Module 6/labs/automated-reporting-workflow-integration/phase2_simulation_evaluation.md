# Phase 2 Simulation Evaluation

Use this document after running `monthly_reporting_pipeline.py`.

## Pipeline Run Details

- Student/team:
- Report month:
- Run date:
- Scheduler approach selected:
- SQL Server used: Yes / No
- Email mode: Dry run / Sent

## Scheduling Reliability

| Benchmark | Evidence | Pass/Fail |
| --- | --- | --- |
| Start time is logged | `outputs/monthly_report_run_log.jsonl` |  |
| Completion time is logged | `outputs/monthly_report_run_log.jsonl` |  |
| Run status is logged | `outputs/monthly_report_run_log.jsonl` |  |
| Failure behavior is documented | scheduling decision log |  |

## Output Quality

| Benchmark | Evidence | Pass/Fail |
| --- | --- | --- |
| Executive HTML report generated | `outputs/monthly_executive_report_YYYY-MM.html` |  |
| Report includes key metrics | HTML report cards and summary |  |
| Report includes benchmark results | HTML report table |  |
| Metrics JSON generated | `outputs/monthly_metrics_YYYY-MM.json` |  |

## Stakeholder Communication

| Benchmark | Evidence | Pass/Fail |
| --- | --- | --- |
| Stakeholder groups configured | `config/reporting_config.json` |  |
| Email body generated | `outputs/monthly_email_preview_YYYY-MM.txt` |  |
| Recommendation included | email preview and report |  |
| Delivery mode documented | run log and email preview |  |

## Overall Assessment

- Main strength of the pipeline:
- Main risk or gap:
- Change required before production deployment:
- Final pass/fail judgement:
