# cron Setup

Use this guide when the monthly reporting workflow runs on Linux.

## When to Use cron

Use cron when:

- the workflow runs on a Linux server
- the schedule is time-based
- the Python environment path is stable
- logs are redirected to a known file

## Manual Test

```bash
cd "$HOME/Desktop/Trainingcred Institute/Module 6/labs/automated-reporting-workflow-integration"
../../../.venv/bin/python monthly_reporting_pipeline.py --report-month 2026-06 --dry-run-email
```

## Example crontab Entry

Run at 07:30 on the first day of each month:

```text
30 7 1 * * cd "$HOME/Desktop/Trainingcred Institute/Module 6/labs/automated-reporting-workflow-integration" && ../../../.venv/bin/python monthly_reporting_pipeline.py --dry-run-email >> outputs/cron_monthly_report.log 2>&1
```

## Failure Handling Checklist

- Redirect stdout and stderr to a log file.
- Confirm `outputs/monthly_report_run_log.jsonl` is updated.
- Use absolute paths for Python and the script.
- Keep secrets in `.env`, not in crontab.
- For production, pair cron with monitoring or alerting.
