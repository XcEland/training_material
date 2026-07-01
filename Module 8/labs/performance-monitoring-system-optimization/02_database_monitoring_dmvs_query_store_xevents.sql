-- ============================================================
-- MODULE 8 SQL MONITORING LAB
-- DMVs, Query Store, Extended Events, and monitoring tables.
-- Run each section in a SQL Server query window.
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

-- ------------------------------------------------------------
-- 1. Tables used by the Python logging and dashboard labs.
-- ------------------------------------------------------------

IF OBJECT_ID('dbo.PythonWorkflowLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PythonWorkflowLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        JobID VARCHAR(50) NOT NULL,
        WorkflowName VARCHAR(100) NOT NULL,
        StepName VARCHAR(100) NULL,
        Severity VARCHAR(20) NOT NULL,
        Message NVARCHAR(MAX) NOT NULL,
        RowsProcessed INT NULL,
        DurationSeconds DECIMAL(18,2) NULL,
        LoggedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF OBJECT_ID('dbo.MonitoringMetric', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.MonitoringMetric (
        MetricID INT IDENTITY(1,1) PRIMARY KEY,
        RecordedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        MetricName VARCHAR(100) NOT NULL,
        MetricValue DECIMAL(18,2) NOT NULL,
        WarningThreshold DECIMAL(18,2) NULL,
        CriticalThreshold DECIMAL(18,2) NULL,
        Status VARCHAR(20) NOT NULL,
        SourceSystem VARCHAR(100) NOT NULL
    );
END;
GO

-- ------------------------------------------------------------
-- 2. DMV: current requests.
-- Use this when you want to know what is running now.
-- ------------------------------------------------------------

SELECT
    r.session_id,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    r.wait_type,
    r.blocking_session_id,
    t.text AS sql_text
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;
GO

-- ------------------------------------------------------------
-- 3. DMV: top expensive cached queries.
-- Use this to find queries with high total resource usage.
-- ------------------------------------------------------------

SELECT TOP 10
    qs.execution_count,
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
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_elapsed_time DESC;
GO

-- ------------------------------------------------------------
-- 4. DMV: blocking sessions.
-- A blocking session makes another session wait.
-- ------------------------------------------------------------

SELECT
    blocked.session_id AS blocked_session_id,
    blocked.blocking_session_id,
    blocked.wait_type,
    blocked.wait_time,
    blocked_sql.text AS blocked_query,
    blocker_sql.text AS blocking_query
FROM sys.dm_exec_requests AS blocked
OUTER APPLY sys.dm_exec_sql_text(blocked.sql_handle) AS blocked_sql
LEFT JOIN sys.dm_exec_requests AS blocker
    ON blocked.blocking_session_id = blocker.session_id
OUTER APPLY sys.dm_exec_sql_text(blocker.sql_handle) AS blocker_sql
WHERE blocked.blocking_session_id <> 0;
GO

-- ------------------------------------------------------------
-- 5. Query Store setup.
-- Query Store keeps query performance history.
-- ------------------------------------------------------------

ALTER DATABASE TrainingDB
SET QUERY_STORE = ON;
GO

ALTER DATABASE TrainingDB
SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    QUERY_CAPTURE_MODE = AUTO,
    MAX_STORAGE_SIZE_MB = 256
);
GO

-- Query Store: top resource-consuming queries.
SELECT TOP 10
    q.query_id,
    qt.query_sql_text,
    rs.count_executions,
    rs.avg_duration / 1000.0 AS avg_duration_ms,
    rs.avg_cpu_time / 1000.0 AS avg_cpu_ms,
    rs.avg_logical_io_reads AS avg_logical_reads
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON qt.query_text_id = q.query_text_id
JOIN sys.query_store_plan AS p
    ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON p.plan_id = rs.plan_id
ORDER BY rs.avg_duration DESC;
GO

-- ------------------------------------------------------------
-- 6. Extended Events setup.
-- This captures SQL statements longer than 30 seconds.
-- The slides use an event file. This lab uses a ring buffer so it can run
-- from a query window without needing a server folder such as C:\XE.
-- ------------------------------------------------------------

IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'LongRunningQueries')
BEGIN
    DROP EVENT SESSION LongRunningQueries ON SERVER;
END;
GO

CREATE EVENT SESSION LongRunningQueries
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(
    ACTION (
        sqlserver.sql_text,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.client_app_name
    )
    WHERE duration > 30000000
)
ADD TARGET package0.ring_buffer;
GO

ALTER EVENT SESSION LongRunningQueries
ON SERVER
STATE = START;
GO

-- Read captured Extended Events from the ring buffer.
SELECT
    event_node.value('(event/@name)[1]', 'varchar(100)') AS event_name,
    event_node.value('(event/data[@name="duration"]/value)[1]', 'bigint') / 1000 AS duration_ms,
    event_node.value('(event/action[@name="database_name"]/value)[1]', 'varchar(100)') AS database_name,
    event_node.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)') AS sql_text
FROM (
    SELECT CAST(t.target_data AS XML) AS target_xml
    FROM sys.dm_xe_sessions AS s
    JOIN sys.dm_xe_session_targets AS t
        ON s.address = t.event_session_address
    WHERE s.name = 'LongRunningQueries'
) AS x
CROSS APPLY x.target_xml.nodes('//RingBufferTarget/event') AS n(event_node);
GO

-- Stop the training session when you finish testing it.
-- ALTER EVENT SESSION LongRunningQueries ON SERVER STATE = STOP;
-- GO
