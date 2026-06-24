# Automated Reporting and Workflow Integration

This Module 6 lab builds an automated monthly reporting system that extracts financial data with T-SQL, processes it with Python, renders a Jinja2 executive report, and distributes a formatted stakeholder notification.

The workflow is safe for training:

- SQL Server is used when available.
- Generated fallback data is used when SQL Server is unavailable.
- Email delivery is dry-run by default and writes an email preview file instead of sending.

## Learning Order

1. Review scheduling architecture and decide between Windows Task Scheduler, cron, and Python scheduling libraries.
2. Prepare the SQL Server monthly reporting dataset.
3. Configure environment variables and report settings.
4. Run the monthly reporting pipeline once.
5. Review the generated HTML report and email preview.
6. Run the scheduling demo to understand recurring execution options.
7. Complete the Phase 2 Simulation evaluation.

## Files

```text
Module 6/labs/automated-reporting-workflow-integration/
├── README.md
├── 01_setup_monthly_reporting_dataset.sql
├── monthly_reporting_pipeline.py
├── scheduler_demo.py
├── scheduling_architecture_decision_log.md
├── windows_task_scheduler_setup.md
├── cron_setup.md
├── phase2_simulation_evaluation.md
├── .env.example
├── .env.windows.example
├── config/
│   └── reporting_config.json
├── templates/
│   ├── executive_monthly_report.html.j2
│   └── email_body.txt.j2
└── outputs/
```

## Scheduling Decision

Windows Task Scheduler is appropriate for simple, single-machine workflows where the trigger is time-based and the environment is stable.

Python scheduling libraries such as `schedule` are useful when workflow logic controls execution timing, retries, failure handling, or multi-environment behavior.

For production Central Bank systems, always pair the scheduler with logging that records:

- execution start time
- completion time
- outcome
- generated report path
- notification status
- failure message when applicable

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

If SQL Server is available:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 6/labs/automated-reporting-workflow-integration/01_setup_monthly_reporting_dataset.sql"
```

Create a local environment file:

```bash
cd "Module 6/labs/automated-reporting-workflow-integration"
cp .env.example .env
```

Run the monthly pipeline:

```bash
python monthly_reporting_pipeline.py --report-month 2026-06
```

Run email dry-run explicitly:

```bash
python monthly_reporting_pipeline.py --report-month 2026-06 --dry-run-email
```

## Windows Setup

From PowerShell:

```powershell
cd "$HOME\Desktop\Trainingcred Institute"
.\.venv\Scripts\Activate.ps1
pip install -r Setup\requirements.txt

sqlcmd -S localhost -E -C -i "Module 6\labs\automated-reporting-workflow-integration\01_setup_monthly_reporting_dataset.sql"

cd "Module 6\labs\automated-reporting-workflow-integration"
copy .env.windows.example .env.windows
python monthly_reporting_pipeline.py --report-month 2026-06 --env .env.windows
```

## Expected Outputs

```text
outputs/monthly_executive_report_2026-06.html
outputs/monthly_email_preview_2026-06.txt
outputs/monthly_metrics_2026-06.json
outputs/monthly_report_run_log.jsonl
outputs/phase2_pipeline_evaluation_2026-06.json
```

## Exercise Deliverable

Submit:

- completed `scheduling_architecture_decision_log.md`
- generated executive HTML report
- generated email preview or proof of email delivery
- generated benchmark evaluation JSON
- completed `phase2_simulation_evaluation.md`
