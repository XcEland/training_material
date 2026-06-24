# Performance Monitoring and System Optimization

This Module 8 lab moves from basic monitoring concepts to a full operational dashboard. It includes SQL Server monitoring scripts, Python profiling demos, production logging patterns, capacity planning worksheets, and a dashboard generator.

The scripts are safe for classroom use:

- SQL Server monitoring queries run when SQL Server is available.
- Python scripts generate fallback sample metrics when SQL Server is unavailable.
- Runtime logs and dashboard outputs are written to `outputs/`.

## Learning Order

1. Run the SQL setup and monitoring script if SQL Server is available.
2. Complete the monitoring tool selection worksheet for DMVs, Query Store, and Extended Events.
3. Run Python profiling and memory demos.
4. Run the production logging demo.
5. Complete performance baseline and dashboard architecture worksheets.
6. Generate the monitoring dashboard.
7. Run the tests and assess the dashboard against alert thresholds.

## Files

```text
Module 8/labs/performance-monitoring-system-optimization/
├── README.md
├── 01_database_monitoring_dmvs_query_store_xevents.sql
├── 02_python_profiling_memory_demo.py
├── 03_logging_error_tracking_demo.py
├── 04_capacity_planning_baseline.py
├── 05_monitoring_dashboard.py
├── db_utils.py
├── monitoring_tool_selection.md
├── python_logging_design.md
├── worksheet_8_1_performance_baseline.md
├── worksheet_8_2_dashboard_architecture.md
├── operational_observability_review.md
├── config/
│   └── monitoring_thresholds.json
├── templates/
│   └── monitoring_dashboard.html.j2
├── tests/
│   └── test_monitoring_dashboard.py
└── outputs/
```

## Monitoring Hierarchy

Dynamic Management Views, DMVs, provide point-in-time snapshots of current server state. They are useful for immediate diagnosis.

Query Store persists query performance history across server restarts. It is essential for trend analysis and regression detection after deployments.

Extended Events is the low-overhead event tracing framework for capturing specific high-frequency events without the performance cost of SQL Profiler.

For Central Bank production systems, all three should be active and reviewed on a defined schedule.

## Python Logging Standard

Use Python's built-in `logging` module with these severity rules:

- `DEBUG`: detailed diagnostics during development
- `INFO`: successful stage completion
- `WARNING`: data quality anomalies that do not halt execution
- `ERROR`: caught exceptions that are handled
- `CRITICAL`: failures that halt the pipeline

Production scripts should write logs to both:

- a rotating file handler
- a database logging table or audit store

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

If SQL Server is available:

```bash
sqlcmd -S localhost,1433 -U sa -P 'StrongPassw0rd!2026' -C -i "Module 8/labs/performance-monitoring-system-optimization/01_database_monitoring_dmvs_query_store_xevents.sql"
```

Run the Python labs:

```bash
cd "Module 8/labs/performance-monitoring-system-optimization"
python 02_python_profiling_memory_demo.py
python 03_logging_error_tracking_demo.py
python 04_capacity_planning_baseline.py
python 05_monitoring_dashboard.py
pytest -q
```

## Expected Outputs

```text
outputs/profile_summary.json
outputs/memory_summary.json
outputs/python_workflow.log
outputs/capacity_projection.json
outputs/monitoring_dashboard.html
outputs/monitoring_snapshot.json
```

## Exercise Deliverable

Submit:

- completed `monitoring_tool_selection.md`
- completed `python_logging_design.md`
- completed Worksheet 8.1
- completed Worksheet 8.2
- generated dashboard HTML
- generated monitoring snapshot JSON
- completed `operational_observability_review.md`
