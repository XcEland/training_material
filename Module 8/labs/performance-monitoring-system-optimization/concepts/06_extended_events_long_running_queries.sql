-- Extended Events Long-Running Queries Script
-- Purpose: capture completed SQL statements longer than 30 seconds.
-- Use this when you need SQL Server to record slow queries over time.

CREATE EVENT SESSION LongRunningQueries
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(
    -- Capture useful context with each completed statement.
    ACTION (
        sqlserver.sql_text,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.client_app_name
    )
    -- duration is in microseconds, so 30000000 means 30 seconds.
    WHERE duration > 30000000
)
ADD TARGET package0.event_file
(
    -- SQL Server must have permission to write to this folder.
    SET filename = 'C:\XE\LongRunningQueries.xel'
);
GO

-- Start the event session after creating it.
ALTER EVENT SESSION LongRunningQueries
ON SERVER
STATE = START;

-- To Check If The Session Exists

SELECT
    name,
    event_session_id
    -- create_time
FROM sys.server_event_sessions
WHERE name = 'LongRunningQueries';

-- To Check If The Session Exists
SELECT
    name,
    create_time
FROM sys.dm_xe_sessions
WHERE name = 'LongRunningQueries';

-- To See The Events In The Session
SELECT
    s.name AS session_name,
    e.name
FROM sys.server_event_sessions AS s
JOIN sys.server_event_session_events AS e
    ON s.event_session_id = e.event_session_id
WHERE s.name = 'LongRunningQueries';


-- To See The Target
SELECT
    s.name AS session_name,
    t.name
FROM sys.server_event_sessions AS s
JOIN sys.server_event_session_targets AS t
    ON s.event_session_id = t.event_session_id
WHERE s.name = 'LongRunningQueries';


-- To Read The .xel File
SELECT
    event_data.value('(event/@name)[1]', 'varchar(100)') AS event_name,
    event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') / 1000 AS duration_ms,
    event_data.value('(event/action[@name="database_name"]/value)[1]', 'varchar(100)') AS database_name,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text
FROM (
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file(
        'C:\XE\LongRunningQueries*.xel',
        NULL,
        NULL,
        NULL
    )
) AS x;