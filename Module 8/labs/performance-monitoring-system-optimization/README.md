# Performance Monitoring and System Optimization

This Module 8 lab moves from basic monitoring concepts to a full operational dashboard. It includes SQL Server monitoring scripts, Python profiling demos, production logging patterns, capacity planning worksheets, and a dashboard generator.

The scripts are safe to run in a local lab environment:

- SQL Server monitoring queries run when SQL Server is available.
- Python scripts generate fallback sample metrics when SQL Server is unavailable.
- Runtime logs and dashboard outputs are written to `outputs/`.

## Learning Order

1. Run `00_monitoring_data_walkthrough.py` to see how Module 6 and Module 7 outputs become monitoring data.
2. Read `day8_learning_guide.md` for the full Day 8 flow and final deliverable.
3. Run `01_beginner_sql_monitoring_walkthrough.sql` if SQL Server is available.
4. Run the full SQL monitoring script if SQL Server is available.
5. Complete the monitoring tool selection worksheet for DMVs, Query Store, and Extended Events.
6. Run Python profiling and memory demos.
7. Run the production logging demo.
8. Complete performance baseline and dashboard architecture worksheets.
9. Generate the monitoring dashboard.
10. Run the dashboard observability assessment and tests.

## Files

```text
Module 8/labs/performance-monitoring-system-optimization/
├── README.md
├── 00_monitoring_data_walkthrough.py
├── 01_beginner_sql_monitoring_walkthrough.sql
├── 02_database_monitoring_dmvs_query_store_xevents.sql
├── 03_python_profiling_memory_demo.py
├── 04_logging_error_tracking_demo.py
├── 05_capacity_planning_baseline.py
├── 06_monitoring_dashboard.py
├── 07_dashboard_observability_assessment.py
├── 08_web_dashboard_server.py
├── day8_learning_guide.md
├── db_utils.py
├── monitoring_data_sources.py
├── monitoring_tool_selection.md
├── python_logging_design.md
├── worksheet_8_1_performance_baseline.md
├── worksheet_8_2_dashboard_architecture.md
├── operational_observability_review.md
├── .env.example
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
- `dbo.PythonWorkflowLog` for database audit logging

Dashboard metrics can also be saved to `dbo.MonitoringMetric`. The metric table uses `MetricID` and `RecordedAt` field names.

## Local Setup

From the repository root:

```bash
cd "$HOME/Desktop/Trainingcred Institute"
source .venv/bin/activate
pip install -r Setup/requirements.txt
```

If SQL Server is available:

```bash
sqlcmd -S localhost,1433 -U sa -P '<your-password>' -C -i "Module 8/labs/performance-monitoring-system-optimization/01_beginner_sql_monitoring_walkthrough.sql"
sqlcmd -S localhost,1433 -U sa -P '<your-password>' -C -i "Module 8/labs/performance-monitoring-system-optimization/02_database_monitoring_dmvs_query_store_xevents.sql"
```

You can also open the SQL files in SQL Server Management Studio or Azure Data Studio and execute them in a query window.

For Python SQL logging and metric history, copy `.env.example` to `.env` and enter your local SQL Server details. Do not commit real database passwords.

Run the Python labs:

```bash
cd "Module 8/labs/performance-monitoring-system-optimization"
python3 00_monitoring_data_walkthrough.py
python3 03_python_profiling_memory_demo.py
python3 04_logging_error_tracking_demo.py
python3 04_logging_error_tracking_demo.py --level DEBUG
python3 05_capacity_planning_baseline.py
python3 06_monitoring_dashboard.py
python3 07_dashboard_observability_assessment.py
python3 08_web_dashboard_server.py
pytest -q
```

## Web Dashboard

Yes, the monitoring output is a web page. Run:

```bash
python3 06_monitoring_dashboard.py
```

Then open:

```text
outputs/monitoring_dashboard.html
```

The HTML file includes database performance panels, Python profiling metrics, Module 6 reporting status, Module 7 quality gate status, workflow run details, capacity projections, and pass/fail observability checks.

For a browser URL during class, run the local dashboard server:

```bash
python3 08_web_dashboard_server.py
```

Then open:

```text
http://localhost:8008/
```

The server regenerates the dashboard whenever the page is loaded. The page also refreshes every 60 seconds. The raw dashboard data is available at:

```text
http://localhost:8008/metrics.json
```

## Expected Outputs

```text
outputs/profile_summary.json
outputs/memory_summary.json
outputs/optimization_beginner_summary.json
outputs/profile_source_summary.json
outputs/python_workflow.log
outputs/workflow_observations.json
outputs/capacity_projection.json
outputs/monitoring_dashboard.html
outputs/monitoring_snapshot.json
outputs/dashboard_observability_assessment.json
```

## Dataset Linkage

This lab monitors artifacts from earlier course work instead of using unrelated sample data:

- Module 6 WEO monthly reporting run logs, executive reports, and email preview status
- Module 7 IMF DataMapper and BIS policy-rate integration summary files
- Module 7 quality gate alert output

The result is a realistic operations view: database health from SQL Server, Python workflow runtime from profiling/logging, data quality status from the external integration pipeline, and capacity projections from observed row and output sizes.

## Exercise Deliverable

Submit:

- completed `monitoring_tool_selection.md`
- completed `python_logging_design.md`
- completed Worksheet 8.1
- completed Worksheet 8.2
- generated dashboard HTML
- generated monitoring snapshot JSON
- generated dashboard observability assessment JSON
- completed `operational_observability_review.md`
