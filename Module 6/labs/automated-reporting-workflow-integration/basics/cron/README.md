# Cron Jobs Inside Python Code

This beginner folder shows the second scheduling pattern:

```text
Linux cron / Windows Task Scheduler
  The operating system starts your script.

Cron-like scheduling inside Python
  Your Python application stays running and calls functions on a schedule.
```

## Lesson Order

1. `01_function_interval_scheduler.py` - run a function every few seconds.
2. `02_function_daily_time_scheduler.py` - run a function at a specific time.
3. `03_cron_expression_function_scheduler.py` - check a simple five-field cron expression.
4. `04_monthly_report_function_trigger.py` - wrap the Module 6 monthly report email trigger inside a scheduled function.

## Run

From this folder:

```bash
../../../../.venv/bin/python 01_function_interval_scheduler.py
../../../../.venv/bin/python 02_function_daily_time_scheduler.py
../../../../.venv/bin/python 03_cron_expression_function_scheduler.py --force-run
../../../../.venv/bin/python 04_monthly_report_function_trigger.py --demo-once
```

The examples write small logs into:

```text
outputs/
```

## Beginner Rule

Use system schedulers for production when possible. Use in-code scheduling when the application must stay alive and manage its own recurring functions.
