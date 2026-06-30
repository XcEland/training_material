-- Query Store Top Queries Script
-- Purpose: review high-duration queries captured by Query Store.

SELECT TOP 10
    -- Query Store keeps query history beyond the current cache.
    q.query_id,
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
