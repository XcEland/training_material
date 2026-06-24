# DMVs, Query Store, and Extended Events: Monitoring Tool Selection

Use this worksheet during the 09:30 - 10:30 interactive lecture.

## Monitoring Hierarchy

Dynamic Management Views, DMVs, provide point-in-time snapshots of current server state. They are useful for immediate diagnosis.

Query Store persists query performance history across server restarts. It is essential for trend analysis and regression detection after deployments.

Extended Events is the low-overhead event tracing framework for capturing specific, high-frequency events without the performance cost of SQL Profiler.

For Central Bank production systems, all three should be active and their outputs reviewed on a defined schedule.

## Tool Selection Record

For each monitoring tool, record the key DMV, Query Store view, or Extended Event session you would configure for a Central Bank production database, and the specific performance question it answers.

| Tool | Key DMV / Query Store view / XE session | Performance question answered | Review frequency | Owner |
| --- | --- | --- | --- | --- |
| DMV | `sys.dm_exec_requests` | Which queries are running right now and consuming resources? | 15 minutes during business hours | DBA |
| DMV | `sys.dm_exec_query_stats` | Which cached queries have the highest CPU or logical reads? | Daily | DBA |
| DMV | `sys.master_files` | How large are the database files and how fast are they growing? | Weekly | DBA |
| Query Store | `sys.query_store_runtime_stats` | Which queries have regressed after deployment? | Daily after deployments | DBA / Developer |
| Query Store | `sys.query_store_plan` | Which queries have multiple plans or plan instability? | Weekly | DBA |
| Extended Events | `m8_slow_statement_monitor` | Which TrainingDB statements exceed the slow-query threshold? | Continuous capture, daily review | DBA |

## Production Decision

- Which DMV should be checked first during an incident?
- Which Query Store report should be reviewed after deployments?
- Which Extended Events session should run continuously?
- What alert should be sent to the operations team?
