-- DMV Current Requests Query
-- Purpose: identify currently running SQL requests.
-- Use this when the database feels slow right now.

-- Example request:
-- SELECT * FROM Customers;
-- UPDATE Sales SET Amount = 100;
-- EXEC dbo.LoadDailyData;

-- State of request:
-- running
-- suspended
-- runnable
-- sleeping
-- Beginner meaning:
-- running: SQL Server is actively working on it
-- suspended: it is waiting for something
-- runnable: it is ready to run but waiting for CPU

SELECT
    -- Session and command details identify the active request.
    r.session_id,
    r.status,
    r.command,
    -- Time, reads, waits, and blocking show why a request may be slow.
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    r.wait_type,
    r.blocking_session_id,
    -- sql_text is the actual query text currently running.
    t.text AS sql_text
FROM sys.dm_exec_requests AS r
-- This adds the actual SQL text being executed.
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;
