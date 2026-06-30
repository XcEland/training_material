-- Top Expensive Queries DMV Script
-- Purpose: find cached queries with high cumulative resource usage.

SELECT TOP 10
    -- execution_count shows how often the cached query has run.
    qs.execution_count,
    -- Worker time is CPU time. Elapsed time is total duration.
    qs.total_worker_time / 1000 AS total_cpu_ms,
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    qs.total_logical_reads,
    qs.total_logical_writes,
    qs.max_elapsed_time / 1000 AS max_elapsed_ms,
    SUBSTRING(
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (CASE qs.statement_end_offset
                WHEN -1 THEN DATALENGTH(st.text)
                ELSE qs.statement_end_offset
             END - qs.statement_start_offset) / 2
        ) + 1
    ) AS query_text
FROM sys.dm_exec_query_stats AS qs
-- This returns the SQL text for each cached query plan.
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_elapsed_time DESC;
