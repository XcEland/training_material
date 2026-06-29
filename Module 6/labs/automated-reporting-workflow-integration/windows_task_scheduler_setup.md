# Windows Task Scheduler Setup

Use this guide for the Module 6 scheduling architecture exercise.

## When to Use Windows Task Scheduler

Use Windows Task Scheduler when:

- the workflow runs on one Windows machine
- the schedule is time-based
- the Python environment and network access are stable
- operations staff can monitor the task history

## Example Command

Update paths for your machine:

```powershell
$PythonPath = "$HOME\Desktop\Trainingcred Institute\.venv\Scripts\python.exe"
$ScriptPath = "$HOME\Desktop\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration\monthly_reporting_pipeline.py"
$WorkDir = "$HOME\Desktop\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration"
```

Manual test:

```powershell
cd $WorkDir
& $PythonPath $ScriptPath --report-month 2026-06 --env .env.windows --refresh-data --dry-run-email
```

## Create a Scheduled Task

```powershell
$Action = New-ScheduledTaskAction `
    -Execute $PythonPath `
    -Argument "`"$ScriptPath`" --env .env.windows --refresh-data --dry-run-email" `
    -WorkingDirectory $WorkDir

$Trigger = New-ScheduledTaskTrigger `
    -Monthly `
    -DaysOfMonth 1 `
    -At 7:30am

Register-ScheduledTask `
    -TaskName "Module6MonthlyReportingPipeline" `
    -Action $Action `
    -Trigger $Trigger `
    -Description "Runs the Module 6 monthly reporting workflow"
```

## Failure Handling Checklist

- Enable task history.
- Confirm the task account has access to the project folder.
- Confirm the task account has SQL Server access if SQL extraction is required.
- Confirm `outputs/monthly_report_run_log.jsonl` is updated after each run.
- Confirm generated reports appear in `outputs/html/`.
- Confirm the stakeholder email preview appears in `outputs/email/` when `SEND_EMAILS=false`.
- Configure email alerts in the script or monitoring tool for production use.
