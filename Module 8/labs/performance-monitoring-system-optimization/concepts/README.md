# Module 8 Concept Scripts

These are short slide-style snippets for quick demonstrations.

Run SQL files in a SQL Server query window.

For Query Store, run setup first:

```text
05a_query_store_setup_lab.sql
05_query_store_top_queries.sql
```

Run Python files from this folder:

```bash
python3 07_python_timed_pipeline_step.py
python3 08_python_cprofile_bottleneck.py
python3 09_python_rotating_logging_setup.py
```

`10_python_metric_collection_function.py` shows the metric function pattern and expects a SQLAlchemy `engine`.

Extra DMV use-case examples:

```text
11_dmv_query_performance_tuning.sql
12_dmv_os_hardware_waits.sql
13_dmv_memory_buffer_cache.sql
14_dmv_index_contention.sql
```
