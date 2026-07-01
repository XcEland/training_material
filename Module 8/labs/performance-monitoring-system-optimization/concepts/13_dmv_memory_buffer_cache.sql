-- DMV Memory and Buffer Cache Example
-- Use this to check whether SQL Server is often finding data in memory.
-- DMV used:
--   sys.dm_os_performance_counters: SQL Server performance counter values

SELECT
    -- Buffer cache hit ratio shows how often data pages are found in memory.
    object_name,
    counter_name,
    cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name IN (
    'Buffer cache hit ratio',
    'Buffer cache hit ratio base',
    'Page life expectancy'
)
ORDER BY counter_name;

-- Beginner interpretation:
-- Buffer cache hit ratio is used with its base value to estimate memory cache efficiency.
-- Page life expectancy shows how long pages stay in memory.
-- Low memory cache efficiency may mean SQL Server is reading from disk too often.
