-- ============================================================
-- Extended Events: Long-Running Queries
-- For SQL Server running on Linux / Mac Docker
-- Purpose: Capture completed SQL statements longer than 30 seconds
-- Output file: /var/opt/mssql/log/LongRunningQueries.xel
-- ============================================================


-- ============================================================
-- 1. Stop the session if it is already running
-- ============================================================

IF EXISTS (
    SELECT 1
    FROM sys.dm_xe_sessions
    WHERE name = 'LongRunningQueries'
)
BEGIN
    ALTER EVENT SESSION LongRunningQueries
    ON SERVER
    STATE = STOP;
END;
GO


-- ============================================================
-- 2. Drop the old session if it already exists
--    This is important if the old one used C:\XE\...
-- ============================================================

IF EXISTS (
    SELECT 1
    FROM sys.server_event_sessions
    WHERE name = 'LongRunningQueries'
)
BEGIN
    DROP EVENT SESSION LongRunningQueries
    ON SERVER;
END;
GO


-- ============================================================
-- 3. Create the Extended Events session
-- ============================================================

CREATE EVENT SESSION LongRunningQueries
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(
    ACTION (
        sqlserver.sql_text,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.client_app_name,
        sqlserver.session_id
    )

    -- duration is measured in microseconds
    -- 30,000,000 microseconds = 30 seconds
    WHERE duration > 30000000
)
ADD TARGET package0.event_file
(
    SET
        filename = N'/var/opt/mssql/log/LongRunningQueries.xel',
        max_file_size = 20,
        max_rollover_files = 5
);
GO


-- ============================================================
-- 4. Start the Extended Events session
-- ============================================================

ALTER EVENT SESSION LongRunningQueries
ON SERVER
STATE = START;
GO


-- ============================================================
-- 5. Check if the session exists
-- ============================================================

SELECT
    name,
    event_session_id
FROM sys.server_event_sessions
WHERE name = 'LongRunningQueries';
GO


-- ============================================================
-- 6. Check if the session is currently running
-- ============================================================

SELECT
    name,
    create_time
FROM sys.dm_xe_sessions
WHERE name = 'LongRunningQueries';
GO


-- ============================================================
-- 7. Check the events captured by the session
-- ============================================================

SELECT
    s.name AS session_name,
    e.name AS event_name
FROM sys.server_event_sessions AS s
JOIN sys.server_event_session_events AS e
    ON s.event_session_id = e.event_session_id
WHERE s.name = 'LongRunningQueries';
GO


-- ============================================================
-- 8. Check the target file configured for the session
-- ============================================================

SELECT
    s.name AS session_name,
    -- t.name AS target_name,
    CAST(t.target_data AS XML) AS target_data
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t
    ON s.address = t.event_session_address
WHERE s.name = 'LongRunningQueries';
GO


-- ============================================================
-- 9. Test with a long-running query
--    This waits for 31 seconds, so it should be captured.
-- ============================================================

WAITFOR DELAY '00:00:31';
GO


-- ============================================================
-- 10. Read the captured .xel file
-- ============================================================

SELECT
    event_data.value('(event/@name)[1]', 'varchar(100)') AS event_name,

    event_data.value('(event/@timestamp)[1]', 'datetime2') AS event_time_utc,

    event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') / 1000 AS duration_ms,

    event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(100)') AS database_name,

    event_data.value('(event/action[@name="username"]/value)[1]', 'varchar(100)') AS username,

    event_data.value('(event/action[@name="client_app_name"]/value)[1]', 'varchar(200)') AS client_app_name,

    event_data.value('(event/action[@name="session_id"]/value)[1]', 'int') AS session_id,

    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text
FROM (
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file(
        '/var/opt/mssql/log/LongRunningQueries*.xel',
        NULL,
        NULL,
        NULL
    )
) AS x
ORDER BY duration_ms DESC;
GO


-- ============================================================
-- 11. Optional: Stop the session when you no longer need it
--    Uncomment this section if you want to stop capturing.
-- ============================================================

/*
ALTER EVENT SESSION LongRunningQueries
ON SERVER
STATE = STOP;
GO
*/


-- ============================================================
-- 12. Optional: Delete the session completely
--    Uncomment this section only if you want to remove it.
-- ============================================================

/*
DROP EVENT SESSION LongRunningQueries
ON SERVER;
GO
*/