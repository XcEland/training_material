-- DMV Query Performance Tuning Example
-- Use this when you want to see active queries and expensive cached queries.
-- DMVs used:
--   sys.dm_exec_requests: currently running requests
--   sys.dm_exec_query_stats: aggregated CPU, duration, and I/O from cached plans

-- Part 1: queries running right now.
SELECT
    -- session_id identifies the connection running the query.
    r.session_id,
    -- total_elapsed_time is how long the request has been running in ms.
    r.total_elapsed_time,
    -- logical_reads shows how much data SQL Server has read from memory.
    r.logical_reads,
    -- wait_type shows what the query is waiting for, if anything.
    r.wait_type,
    -- text is the SQL statement currently running.
    t.text AS sql_text
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;

-- Part 2: queries with high total CPU and I/O in the plan cache.
SELECT TOP 10
    -- execution_count shows how many times this cached query ran.
    qs.execution_count,
    -- total_cpu_ms helps find CPU-heavy queries.
    qs.total_worker_time / 1000 AS total_cpu_ms,
    -- total_elapsed_ms helps find long-running queries.
    qs.total_elapsed_time / 1000 AS total_elapsed_ms,
    -- total_logical_reads helps find read-heavy queries.
    qs.total_logical_reads,
    -- text is the cached SQL statement.
    t.text AS sql_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS t
ORDER BY qs.total_worker_time DESC;
