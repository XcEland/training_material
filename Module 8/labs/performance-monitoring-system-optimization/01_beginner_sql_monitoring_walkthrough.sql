-- ============================================================
-- MODULE 8 BEGINNER SQL WALKTHROUGH
-- Run this first in a SQL Server query window.
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

-- ------------------------------------------------------------
-- 1. Create the workflow log table from the slides.
-- Python will write one row for each important workflow event.
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

-- ------------------------------------------------------------
-- 2. Create the metric table.
-- The slide used "Snapshot"; this lab uses MetricID and RecordedAt instead.
-- ------------------------------------------------------------

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
-- 3. Insert one simple log row.
-- This shows the shape that the Python logging script will use.
-- ------------------------------------------------------------

INSERT INTO dbo.PythonWorkflowLog
    (JobID, WorkflowName, StepName, Severity, Message, RowsProcessed, DurationSeconds)
VALUES
    ('M8-DEMO-001', 'Module 8 SQL Walkthrough', 'Setup', 'INFO',
     'Monitoring tables are ready.', 0, 0.00);
GO

SELECT TOP 10
    LogID,
    LoggedAt,
    WorkflowName,
    StepName,
    Severity,
    Message
FROM dbo.PythonWorkflowLog
ORDER BY LogID DESC;
GO

-- ------------------------------------------------------------
-- 4. DMV example: who is connected right now?
-- DMV means Dynamic Management View.
-- ------------------------------------------------------------

SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status
FROM sys.dm_exec_sessions
WHERE is_user_process = 1
ORDER BY session_id;
GO

-- ------------------------------------------------------------
-- 5. DMV example: what SQL requests are running right now?
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
-- 6. Database file size.
-- Capacity planning starts with a simple size check.
-- ------------------------------------------------------------

SELECT
    DB_NAME(database_id) AS database_name,
    type_desc,
    name AS logical_file_name,
    CAST(size * 8.0 / 1024 AS DECIMAL(18,2)) AS size_mb
FROM sys.master_files
WHERE database_id = DB_ID('TrainingDB')
ORDER BY type_desc, name;
GO

-- Next: run 02_database_monitoring_dmvs_query_store_xevents.sql
