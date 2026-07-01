-- SQL Server Wait Statistics Query
-- Purpose: understand what SQL Server is waiting on.
-- Use this to identify broad pressure such as CPU, I/O, locks, or memory.

SELECT TOP 15
    -- wait_type names the resource SQL Server is waiting for.
    wait_type,
    -- waiting_tasks_count shows how many waits happened.
    waiting_tasks_count,
    -- signal_wait_time_ms is time waiting for CPU after the resource is ready.
    wait_time_ms,
    max_wait_time_ms,
    signal_wait_time_ms,
    wait_time_ms - signal_wait_time_ms AS resource_wait_ms
FROM sys.dm_os_wait_stats
-- Sleep waits are usually idle background waits
WHERE wait_type NOT LIKE 'SLEEP%'
ORDER BY wait_time_ms DESC;
