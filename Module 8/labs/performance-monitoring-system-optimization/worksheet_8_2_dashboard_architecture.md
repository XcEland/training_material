# Worksheet 8.2: Monitoring Dashboard Architecture Design

Design the architecture of the comprehensive monitoring dashboard you build in the Data Lab exercise.

For each dashboard panel, specify what it displays, the data source, the refresh frequency, and the alerting logic.

| Dashboard Panel | What It Displays | Data Source | Refresh Frequency | Alerting Logic |
| --- | --- | --- | --- | --- |
| Active Sessions | Current user sessions | DMV: `sys.dm_exec_sessions` | 5 minutes | Warning >20, Critical >50 |
| Running Requests | Long-running active queries | DMV: `sys.dm_exec_requests` | 1 minute during incidents | Alert when elapsed time > threshold |
| Query Regression | Query duration and plan regressions | Query Store views | Daily and after deployments | Alert when avg duration doubles |
| Slow Statements | Statement events over slow threshold | Extended Events session | Continuous capture, dashboard every 15 minutes | Alert when event count increases |
| Python Workflow Duration | Runtime of ETL/automation scripts | `cProfile` output and logs | Each run | Warning >5 sec, Critical >15 sec |
| Python Memory | Peak memory use | `tracemalloc` output | Each run | Warning >100 MB, Critical >250 MB |
| Error Tracking | WARNING/ERROR/CRITICAL counts | Rotating file and database log table | Each run | Alert on ERROR/CRITICAL |
| Module 6 Reporting Status | WEO report generation, email preview status, output count | Module 6 monthly report run log | Each scheduled reporting run | Alert if status is not succeeded |
| Module 7 Quality Gate Status | Accepted rows, rejected rows, quality issue count | Module 7 external integration summary and alert JSON | Each external data load | Alert if quality gate fails |
| Capacity Projection | Row/storage growth over 12 months | Baseline worksheet and projection script | Monthly | Alert if projected storage breaches threshold |

## Architecture Notes

- Dashboard owner:
- Source database:
- Refresh mechanism:
- Alert channel:
- Retention period:
- Production hardening required:
