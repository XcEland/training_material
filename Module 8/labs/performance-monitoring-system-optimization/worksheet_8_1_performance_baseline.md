# Worksheet 8.1: Performance Baseline Establishment Record

During the capacity planning case study and monitoring dashboard lab, establish a performance baseline for the database and Python workflow environment you are working with.

Record each metric, its current measured value, the acceptable operating range, and the alert threshold you would configure.

| Performance Metric | Measurement Tool (DMV / Query Store / Python profiler) | Current Measured Value | Acceptable Operating Range | Alert Threshold | Escalation Action When Threshold Breached |
| --- | --- | --- | --- | --- | --- |
| Active SQL sessions | DMV: `sys.dm_exec_sessions` |  | 0-20 | >20 warning, >50 critical | DBA checks blocking and workload |
| Average query duration | Query Store: `sys.query_store_runtime_stats` |  | <500 ms | >500 ms warning, >2000 ms critical | Review execution plan and indexes |
| Database size | DMV: `sys.master_files` |  | <1024 MB training baseline | >1024 MB warning, >4096 MB critical | Review retention and growth plan |
| Python workflow duration | `cProfile` |  | <5 sec | >5 sec warning, >15 sec critical | Profile bottleneck functions |
| Python peak memory | `tracemalloc` |  | <100 MB | >100 MB warning, >250 MB critical | Review data structures and chunking |
| Python error count | log file/database log |  | 0 | >=1 warning, >=3 critical | Investigate exceptions and alert owner |
| Module 6 reporting runtime | Module 6 run log / dashboard snapshot |  | agreed reporting SLA | breach of monthly reporting SLA | Notify reporting owner |
| Module 7 quality issue count | Module 7 quality gate alert |  | 0 unresolved issues | >=1 warning, >=3 critical | Reject load and alert data owner |
| Output storage size | Module 6/7 output folders |  | depends on retention policy | projected breach within planning window | Review retention and archive policy |

## Baseline Notes

- Date captured:
- Environment:
- Database:
- Workload tested:
- Known limitations:
