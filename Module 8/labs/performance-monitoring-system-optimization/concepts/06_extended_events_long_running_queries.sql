-- Extended Events Long-Running Queries Script
-- Purpose: capture completed SQL statements longer than 30 seconds.

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
