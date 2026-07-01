-- DMV OS and Hardware Diagnostics Example
-- Use this when SQL Server feels slow and you need to see resource waits.
-- DMV used:
--   sys.dm_os_wait_stats: accumulated SQL Server wait information

SELECT TOP 15
    -- wait_type names what SQL Server waited for.
    wait_type,
    -- waiting_tasks_count shows how many waits happened.
    waiting_tasks_count,
    -- wait_time_ms is total wait time.
    wait_time_ms,
    -- signal_wait_time_ms is time waiting for CPU after the resource was ready.
    signal_wait_time_ms,
    -- resource_wait_ms is time waiting for the actual resource.
    wait_time_ms - signal_wait_time_ms AS resource_wait_ms
FROM sys.dm_os_wait_stats
-- These waits are usually idle/background waits, so hide them in beginner demos.
WHERE wait_type NOT LIKE 'SLEEP%'
  AND wait_type NOT LIKE 'BROKER%'
ORDER BY wait_time_ms DESC;

-- Beginner interpretation:
-- High PAGEIOLATCH waits can point to I/O pressure.
-- High SOS_SCHEDULER_YIELD waits can point to CPU pressure.
-- High LCK waits can point to blocking or locking.
