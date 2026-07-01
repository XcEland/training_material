-- Query Store Top Queries Script
-- Purpose: review high-duration queries captured by Query Store.
-- Use this to find queries that have been slow over time.
-- Run 05a_query_store_setup_lab.sql first if Query Store is not enabled.

USE TrainingDB;
GO

-- These sys.query_store_* objects are built-in system views.
-- They are not user tables that you created.
-- They show Query Store data for the current database: TrainingDB.

SELECT TOP 10
    -- Query Store keeps query history beyond the current cache.
    q.query_id,
    -- query_sql_text is the SQL statement captured by Query Store.
    qt.query_sql_text,
    -- Average duration and CPU help identify regressions.
    rs.count_executions,
    rs.avg_duration / 1000.0 AS avg_duration_ms,
    rs.avg_cpu_time / 1000.0 AS avg_cpu_ms,
    rs.avg_logical_io_reads AS avg_logical_reads
FROM sys.query_store_query_text AS qt
-- Join query text, query, plan, and runtime statistics together.
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
ORDER BY rs.avg_duration DESC;


SELECT
    actual_state_desc,
    desired_state_desc,
    query_capture_mode_desc,
    max_storage_size_mb,
    current_storage_size_mb
FROM sys.database_query_store_options;

USE TrainingDB;
GO

-- That should list Query Store system views such as:

SELECT TOP 10
    name,
    object_id,
    type_desc
FROM sys.system_views
WHERE name LIKE 'query_store%'
ORDER BY name;
