# cron Setup

Use this guide when the monthly reporting workflow runs on Linux.

## When to Use cron

Use cron when:

- the workflow runs on a Linux server
- the schedule is time-based
- the Python environment path is stable
- logs are redirected to a known file

## System cron vs In-Code Scheduling

There are two useful patterns:

```text
System cron
  Linux starts the Python script at the scheduled time.

Cron-like scheduling inside Python
  Python stays running and calls a function on a schedule.
```

The second pattern is demonstrated in:

```text
cron-in-code-basics/
```

Start with:

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 6/labs/automated-reporting-workflow-integration/cron-in-code-basics"
../../../../.venv/bin/python 01_function_interval_scheduler.py
../../../../.venv/bin/python 03_cron_expression_function_scheduler.py --force-run
../../../../.venv/bin/python 04_monthly_report_function_trigger.py --demo-once
```

Use system cron when the operating system should own the schedule. Use in-code scheduling when the application must stay running and trigger multiple internal functions.

## Manual Test

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 6/labs/automated-reporting-workflow-integration"
../../../.venv/bin/python 06_monthly_reporting_pipeline.py --report-month 2026-06 --refresh-data --dry-run-email
```

## Example crontab Entry

Run at 07:30 on the first day of each month:

```text
30 7 1 * * cd "$HOME/Desktop/Trainingcred Institute/Module 6/labs/automated-reporting-workflow-integration" && ../../../.venv/bin/python 06_monthly_reporting_pipeline.py --refresh-data --dry-run-email >> outputs/cron_monthly_report.log 2>&1
```

## Failure Handling Checklist

- Redirect stdout and stderr to a log file.
- Confirm `outputs/monthly_report_run_log.jsonl` is updated.
- Confirm generated reports appear in `outputs/html/`.
- Confirm the stakeholder email preview appears in `outputs/email/` when `SEND_EMAILS=false`.
- Use absolute paths for Python and the script.
- Keep secrets in `.env`, not in crontab.
- For production, pair cron with monitoring or alerting.
