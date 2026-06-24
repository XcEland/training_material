# Scheduling Architecture Decision Log

Use this log during the 09:30 - 10:30 Module 6 session.

For each scheduling approach discussed, record the setup requirement, failure handling behavior, and the Central Bank workflow scenario where it is the better choice.

## Scheduling Decision Summary

Windows Task Scheduler is appropriate for simple, single-machine workflows where the trigger is time-based and the environment is stable.

Python scheduling libraries such as `schedule` or APScheduler are preferable when workflow logic itself needs to determine execution timing, handle failures gracefully, or run across multiple environments.

For production Central Bank systems, always pair any scheduler with logging that records execution start time, completion time, and outcome.

## Comparison Table

| Scheduling approach | Setup requirement | Failure handling behavior | Better Central Bank workflow scenario | Decision notes |
| --- | --- | --- | --- | --- |
| Windows Task Scheduler | Windows machine, Python path, script path, service account permissions | Can retry through task settings; logs task history; script must write its own detailed run log | Monthly report on a stable analyst workstation or reporting server |  |
| cron | Linux server, crontab entry, Python path, environment file | Basic scheduling; failures need redirected logs and script-level error handling | Linux-hosted automated extraction/reporting job |  |
| Python `schedule` library | Long-running Python process or service wrapper | Must be coded explicitly with try/except, logging, and alerting | Classroom demo, lightweight local automation, workflow timing controlled by Python logic |  |
| Managed orchestrator | Platform account, deployment package, monitoring configuration | Strong monitoring, retries, alerting, and audit trail | Production-grade critical reporting pipeline |  |

## Required Logging Design

Your pipeline must record:

- start time
- completion time
- status
- report month
- generated output path
- email status
- error message when failed

## Final Architecture Choice

- Selected scheduler:
- Why this scheduler fits the workflow:
- Required service account or credentials:
- Where logs will be stored:
- How failures will be detected:
- Who receives failure notifications:
