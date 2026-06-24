# Python Logging Framework Design

Use this worksheet during the 11:45 - 13:00 guided practice.

## Logging Standard

Python's built-in `logging` module supports five severity levels: `DEBUG`, `INFO`, `WARNING`, `ERROR`, and `CRITICAL`.

For production ETL and automation scripts at the Central Bank, configure at minimum:

- `INFO` for every successful pipeline stage completion
- `WARNING` for data quality anomalies that do not halt execution
- `ERROR` for exceptions that are caught and handled
- `CRITICAL` for failures that halt the pipeline

Write logs to both a rotating file handler and a database logging table for audit trail purposes.

## Script Selected for Logging Design

- Script name:
- Business purpose:
- Production owner:
- Log retention owner:

## Logging Configuration

| Logging event | Log level | Message format | Handler type | Retention policy |
| --- | --- | --- | --- | --- |
| Pipeline started | INFO | timestamp, workflow, stage, message | rotating file + database | 90 days |
| Stage completed | INFO | timestamp, workflow, stage, duration, rows | rotating file + database | 90 days |
| Data quality anomaly | WARNING | timestamp, workflow, rule, rejected row count | rotating file + database | 180 days |
| Recoverable exception | ERROR | timestamp, workflow, exception type, message | rotating file + database | 180 days |
| Pipeline halted | CRITICAL | timestamp, workflow, stage, exception, escalation action | rotating file + database + alert | 1 year |

## Required Fields

- timestamp
- workflow name
- stage name
- severity
- message
- duration
- rows processed
- exception details where applicable

## Design Notes

- Where will log files be stored?
- Which table stores database logs?
- How large can each log file become before rotation?
- How many backup log files are retained?
- Who receives CRITICAL alerts?
