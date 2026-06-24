# Module 8: Performance Monitoring and System Optimization

Module 8 teaches production observability for SQL Server and Python workflows. Students use DMVs, Query Store, and Extended Events for database monitoring; Python profiling and memory tools for script optimization; logging frameworks for maintainability; and baseline/capacity planning records for operational decision-making.

## Lab

```text
Module 8/labs/performance-monitoring-system-optimization/
```

The lab covers:

- SQL Server monitoring with DMVs, Query Store, and Extended Events
- Python profiling with `cProfile`, `pstats`, and `tracemalloc`
- production logging with rotating file handlers and optional SQL logging
- error tracking and debugging strategies
- capacity planning and scalability assessment
- monitoring dashboard generation for database and Python workflow metrics
- alert-threshold assessment against operational observability standards

The lab uses `TrainingDB` and creates objects under the `m8` schema when SQL Server is available. Python scripts also include fallback sample metrics so exercises run without SQL Server.
