# Windows Task Scheduler Setup

Use this guide for the Module 6 scheduling architecture exercise.

## Beginner Smoke Test

Before scheduling the full monthly reporting pipeline, schedule this simple script first:

```text
02_windows_task_scheduler_smoke_test.py
```

The script writes one line to:

```text
outputs/task_scheduler_smoke_test.txt
```

Manual test in PowerShell:

```powershell
$PythonPath = "$HOME\Desktop\Trainingcred Institute\.venv\Scripts\python.exe"
$WorkDir = "$HOME\Desktop\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration"
$SmokeTestScript = "$WorkDir\02_windows_task_scheduler_smoke_test.py"

cd $WorkDir
& $PythonPath $SmokeTestScript
Get-Content "$WorkDir\outputs\task_scheduler_smoke_test.txt"
```

### Create The Smoke Test Task With The GUI

1. Open **Task Scheduler**.
2. Select **Create Basic Task**.
3. Name it `Module6SmokeTest`.
4. Choose a trigger, such as **One time** or **Daily**.
5. Choose **Start a program**.
6. Program/script:

```text
C:\path\to\Trainingcred Institute\.venv\Scripts\python.exe
```

7. Add arguments:

```text
"C:\path\to\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration\02_windows_task_scheduler_smoke_test.py"
```

8. Start in:

```text
C:\path\to\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration
```

9. Run the task manually and confirm `outputs\task_scheduler_smoke_test.txt` has a new timestamp.

### Create The Smoke Test Task With PowerShell

```powershell
$PythonPath = "$HOME\Desktop\Trainingcred Institute\.venv\Scripts\python.exe"
$WorkDir = "$HOME\Desktop\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration"
$SmokeTestScript = "$WorkDir\02_windows_task_scheduler_smoke_test.py"

$Action = New-ScheduledTaskAction `
    -Execute $PythonPath `
    -Argument "`"$SmokeTestScript`"" `
    -WorkingDirectory $WorkDir

$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date).AddMinutes(2)

Register-ScheduledTask `
    -TaskName "Module6SmokeTest" `
    -Action $Action `
    -Trigger $Trigger `
    -Description "Writes a timestamp to confirm Windows Task Scheduler can run Python"
```

After the task runs:

```powershell
Get-Content "$WorkDir\outputs\task_scheduler_smoke_test.txt"
```

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
$ScriptPath = "$HOME\Desktop\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration\06_monthly_reporting_pipeline.py"
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

## Schedule The Single-Recipient Email Trigger Lab

Use this task after the smoke test passes and SMTP settings in `.env` are configured.

```powershell
$PythonPath = "$HOME\Desktop\Trainingcred Institute\.venv\Scripts\python.exe"
$WorkDir = "$HOME\Desktop\Trainingcred Institute\Module 6\labs\automated-reporting-workflow-integration"
$EmailTriggerScript = "$WorkDir\07_send_monthly_report_email_trigger.py"

$Action = New-ScheduledTaskAction `
    -Execute $PythonPath `
    -Argument "`"$EmailTriggerScript`" --report-month 2026-06" `
    -WorkingDirectory $WorkDir

$Trigger = New-ScheduledTaskTrigger `
    -Monthly `
    -DaysOfMonth 1 `
    -At 7:45am

Register-ScheduledTask `
    -TaskName "Module6EmailMonthlyReportToFindy" `
    -Action $Action `
    -Trigger $Trigger `
    -Description "Generates the Module 6 Jinja2 monthly reports and emails the report pack to REPORT_TO_EMAIL from .env"
```

Preview version that does not send email:

```powershell
$Action = New-ScheduledTaskAction `
    -Execute $PythonPath `
    -Argument "`"$EmailTriggerScript`" --report-month 2026-06 --dry-run" `
    -WorkingDirectory $WorkDir
```

## Failure Handling Checklist

- Enable task history.
- Confirm the task account has access to the project folder.
- Confirm the task account has SQL Server access if SQL extraction is required.
- Confirm `outputs/monthly_report_run_log.jsonl` is updated after each run.
- Confirm generated reports appear in `outputs/html/`.
- Confirm the stakeholder email preview appears in `outputs/email/` when `SEND_EMAILS=false`.
- Configure email alerts in the script or monitoring tool for production use.
