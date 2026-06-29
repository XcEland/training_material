-- ============================================================
-- MODULE 8 BEGINNER SQL WALKTHROUGH
-- FILE 01A: HOW TO THINK ABOUT SQL SERVER MONITORING
-- ============================================================
--
-- This file is intentionally simpler than the full monitoring script.
-- It helps beginners answer four operational questions:
--
-- 1. Is my database available?
-- 2. Who is connected right now?
-- 3. What SQL requests are running right now?
-- 4. Where will Python workflow logs and dashboard snapshots be stored?
--
-- Run this first. Then run:
-- 01_database_monitoring_dmvs_query_store_xevents.sql
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

-- ------------------------------------------------------------
-- STEP 1: Create simple monitoring tables.
-- These tables are used by the Python logging and dashboard labs.
-- ------------------------------------------------------------

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

-- ------------------------------------------------------------
-- STEP 2: Insert one simple log row.
-- This shows what the Python logging script will write later.
-- ------------------------------------------------------------

INSERT INTO m8.PythonWorkflowExecutionLog
    (WorkflowName, Severity, StageName, Message, DurationMs, RowsProcessed)
VALUES
    ('Module8BeginnerWalkthrough', 'INFO', 'setup', 'Monitoring tables are available.', 0, 0);
GO

SELECT TOP (10)
    LogID,
    CreatedAt,
    WorkflowName,
    Severity,
    StageName,
    Message
FROM m8.PythonWorkflowExecutionLog
ORDER BY LogID DESC;
GO

-- ------------------------------------------------------------
-- STEP 3: DMV example: who is connected right now?
-- DMV means Dynamic Management View.
-- Think of a DMV as a live operational window into SQL Server.
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
-- STEP 4: DMV example: what is running right now?
-- During a real incident, this is often one of the first checks.
-- ------------------------------------------------------------

SELECT
    r.session_id,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time,
    DB_NAME(r.database_id) AS database_name,
    LEFT(t.text, 500) AS sql_text
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@SPID
ORDER BY r.total_elapsed_time DESC;
GO

-- ------------------------------------------------------------
-- STEP 5: Database file size.
-- Capacity planning starts with knowing current storage usage.
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

-- ------------------------------------------------------------
-- NEXT STEP:
-- After this beginner walkthrough, open the full script and compare:
-- - DMVs for current state
-- - Query Store for history and regression detection
-- - Extended Events for low-overhead event capture
-- ------------------------------------------------------------
