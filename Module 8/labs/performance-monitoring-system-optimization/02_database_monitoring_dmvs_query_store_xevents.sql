-- ============================================================
-- MODULE 8 LAB
-- FILE 01: DATABASE MONITORING WITH DMVS, QUERY STORE, EXTENDED EVENTS
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm8')
BEGIN
    EXEC('CREATE SCHEMA m8');
END;
GO

IF OBJECT_ID('m8.PythonWorkflowExecutionLog', 'U') IS NULL
BEGIN
    CREATE TABLE m8.PythonWorkflowExecutionLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        WorkflowName VARCHAR(120) NOT NULL,
        Severity VARCHAR(20) NOT NULL,
        StageName VARCHAR(120) NULL,
        Message NVARCHAR(1000) NOT NULL,
        DurationMs INT NULL,
        RowsProcessed INT NULL
    );
END;
GO

IF OBJECT_ID('m8.PerformanceBaseline', 'U') IS NULL
BEGIN
    CREATE TABLE m8.PerformanceBaseline (
        BaselineID INT IDENTITY(1,1) PRIMARY KEY,
        CapturedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        MetricName VARCHAR(120) NOT NULL,
        MeasurementTool VARCHAR(120) NOT NULL,
        CurrentMeasuredValue DECIMAL(18,4) NULL,
        AcceptableRange VARCHAR(120) NOT NULL,
        AlertThreshold VARCHAR(120) NOT NULL,
        EscalationAction NVARCHAR(500) NOT NULL
    );
END;
GO

IF OBJECT_ID('m8.MonitoringDashboardSnapshot', 'U') IS NULL
BEGIN
    CREATE TABLE m8.MonitoringDashboardSnapshot (
        SnapshotID INT IDENTITY(1,1) PRIMARY KEY,
        CapturedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        MetricName VARCHAR(120) NOT NULL,
        MetricValue DECIMAL(18,4) NULL,
        AlertLevel VARCHAR(20) NOT NULL,
        DataSource VARCHAR(120) NOT NULL
    );
END;
GO

-- ============================================================
-- SECTION 1: DMVs
-- DMVs are point-in-time server views. Use them for immediate diagnosis.
-- ============================================================

-- Current user sessions and wait status.
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status,
    cpu_time,
    memory_usage,
    reads,
    writes
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY cpu_time DESC;
GO

-- Currently running requests.
SELECT
    r.session_id,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time,
    r.logical_reads,
    r.writes,
    DB_NAME(r.database_id) AS database_name,
    SUBSTRING(t.text, 1, 1000) AS sql_text
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;
GO

-- Top cached queries by total worker time.
SELECT TOP (10)
    qs.execution_count,
    qs.total_worker_time,
    qs.total_elapsed_time,
    qs.total_logical_reads,
    qs.total_logical_writes,
    SUBSTRING(st.text, 1, 1000) AS sql_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_worker_time DESC;
GO

-- Database file size and growth view.
SELECT
    DB_NAME(database_id) AS database_name,
    type_desc,
    name AS logical_file_name,
    size * 8.0 / 1024 AS size_mb,
    growth,
    is_percent_growth
FROM sys.master_files
WHERE database_id = DB_ID('TrainingDB')
ORDER BY type_desc, name;
GO

-- ============================================================
-- SECTION 2: Query Store
-- Query Store persists query performance history.
-- Use it for trend analysis and regression detection after deployments.
-- ============================================================

ALTER DATABASE TrainingDB
SET QUERY_STORE = ON;
GO

ALTER DATABASE TrainingDB
SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 900,
    INTERVAL_LENGTH_MINUTES = 60,
    MAX_STORAGE_SIZE_MB = 256,
    QUERY_CAPTURE_MODE = AUTO
);
GO

-- Query Store: top query texts by average duration.
SELECT TOP (10)
    qt.query_sql_text,
    rs.count_executions,
    rs.avg_duration,
    rs.avg_cpu_time,
    rs.avg_logical_io_reads,
    p.last_execution_time
FROM sys.query_store_query_text AS qt
JOIN sys.query_store_query AS q
    ON q.query_text_id = qt.query_text_id
JOIN sys.query_store_plan AS p
    ON p.query_id = q.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON rs.plan_id = p.plan_id
ORDER BY rs.avg_duration DESC;
GO

-- Query Store: queries with multiple plans can indicate plan instability.
SELECT TOP (10)
    q.query_id,
    COUNT(DISTINCT p.plan_id) AS plan_count,
    MIN(p.first_execution_time) AS first_execution_time,
    MAX(p.last_execution_time) AS last_execution_time
FROM sys.query_store_query AS q
JOIN sys.query_store_plan AS p
    ON p.query_id = q.query_id
GROUP BY q.query_id
HAVING COUNT(DISTINCT p.plan_id) > 1
ORDER BY plan_count DESC;
GO

-- ============================================================
-- SECTION 3: Extended Events
-- Extended Events captures specific events with lower overhead than SQL Profiler.
-- This session captures slow statements in TrainingDB.
-- ============================================================

IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'm8_slow_statement_monitor')
BEGIN
    DROP EVENT SESSION m8_slow_statement_monitor ON SERVER;
END;
GO

CREATE EVENT SESSION m8_slow_statement_monitor
ON SERVER
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(
        sqlserver.database_name,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.username
    )
    WHERE
        sqlserver.database_name = N'TrainingDB'
        AND duration >= 1000000 -- microseconds; 1 second
)
ADD TARGET package0.ring_buffer
WITH (
    MAX_MEMORY = 4096 KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 30 SECONDS,
    STARTUP_STATE = OFF
);
GO

ALTER EVENT SESSION m8_slow_statement_monitor ON SERVER STATE = START;
GO

-- Read recent Extended Events from the ring buffer target.
SELECT
    CAST(t.target_data AS XML) AS ring_buffer_xml
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t
    ON s.address = t.event_session_address
WHERE s.name = 'm8_slow_statement_monitor';
GO

-- Stop the training session when done if you do not want it running.
-- ALTER EVENT SESSION m8_slow_statement_monitor ON SERVER STATE = STOP;
-- GO
