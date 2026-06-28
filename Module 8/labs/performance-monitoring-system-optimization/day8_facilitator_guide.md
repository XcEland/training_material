# Day 8 Facilitator Guide: Performance Monitoring and System Optimization

Day 8 moves from building data systems to sustaining them. The running case study is the same Central Bank training environment used in Modules 5-7:

- Module 5 produced WEO analytical outputs and charts.
- Module 6 automated WEO reporting, HTML report generation, email previews, and scheduler-ready run logs.
- Module 7 integrated IMF/BIS external data, applied quality gates, and produced accepted/rejected load summaries.
- Module 8 monitors those workflows and SQL Server health as one operational system.

## Teaching Sequence

| Time | Session | Lab Asset | Facilitator Focus |
| --- | --- | --- | --- |
| 09:00 - 09:30 | Orientation | `day8_facilitator_guide.md` | Monitoring is an operational obligation, not an optional dashboard. |
| 09:30 - 10:30 | Database monitoring | `01a_beginner_sql_monitoring_walkthrough.sql`, then `01_database_monitoring_dmvs_query_store_xevents.sql` | Start with plain questions: who is connected, what is running, what changed, what crossed a threshold? |
| 10:45 - 11:45 | Python profiling | `00_monitoring_data_walkthrough.py`, `02_python_profiling_memory_demo.py` | Show that profiling measures actual code paths, not opinions about performance. |
| 11:45 - 13:00 | Logging and debugging | `03_logging_error_tracking_demo.py`, `python_logging_design.md` | Connect log severity to audit, support, and escalation decisions. |
| 14:00 - 15:00 | Capacity planning | `04_capacity_planning_baseline.py`, `worksheet_8_1_performance_baseline.md` | Baselines are current measured values. Capacity planning is baseline plus growth assumptions. |
| 15:00 - 15:30 | Data lab dashboard | `05_monitoring_dashboard.py`, `06_dashboard_observability_assessment.py` | The dashboard must show database health and Python workflow execution together. |
| 15:45 - 16:30 | Group exercise | `worksheet_8_2_dashboard_architecture.md` | Groups defend panel selection, thresholds, owners, and alert routes. |
| 16:30 - 17:00 | Reflection | `operational_observability_review.md` | Students assess the dashboard against operational observability standards. |

## Beginner Framing

Use these questions before showing tools:

- What is slow right now? Use DMVs.
- What has been getting slower over time? Use Query Store.
- What specific events do we need to capture continuously? Use Extended Events.
- Which Python function takes the most time? Use `cProfile`.
- Which Python step uses the most memory? Use `tracemalloc`.
- What happened, when, and who must investigate? Use structured logging.
- How much growth can the current system absorb? Use baselines and projections.

## Final Deliverable

Students should submit:

- dashboard HTML from `outputs/monitoring_dashboard.html`
- dashboard snapshot JSON from `outputs/monitoring_snapshot.json`
- assessment JSON from `outputs/dashboard_observability_assessment.json`
- completed monitoring tool selection worksheet
- completed logging design worksheet
- completed performance baseline worksheet
- completed dashboard architecture worksheet
- completed operational observability review
