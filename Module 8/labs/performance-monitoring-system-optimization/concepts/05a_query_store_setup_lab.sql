-- Query Store Setup Lab
-- Purpose: turn Query Store on for TrainingDB.
-- Use this before running 05_query_store_top_queries.sql.

-- Query Store is enabled per database.
-- This means TrainingDB gets its own Query Store history.
IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

ALTER DATABASE TrainingDB
SET QUERY_STORE = ON;
GO

-- READ_WRITE means Query Store can collect new query history.
-- AUTO means SQL Server chooses which queries are worth capturing.
-- MAX_STORAGE_SIZE_MB limits how much space Query Store can use.
ALTER DATABASE TrainingDB
SET QUERY_STORE (
    OPERATION_MODE = READ_WRITE,
    QUERY_CAPTURE_MODE = AUTO,
    MAX_STORAGE_SIZE_MB = 256
);
GO

USE TrainingDB;
GO

-- Check whether Query Store is enabled for this database.
SELECT
    actual_state_desc,
    desired_state_desc,
    query_capture_mode_desc,
    max_storage_size_mb,
    current_storage_size_mb
FROM sys.database_query_store_options;
GO

-- Note:
-- The Query Store views live under the sys schema in each database.
-- They are system views, not user-created tables.
-- In Object Explorer, open:
-- Databases > TrainingDB > Views > System Views

SELECT
    actual_state_desc,
    desired_state_desc,
    query_capture_mode_desc,
    max_storage_size_mb,
    current_storage_size_mb
FROM sys.database_query_store_options;

USE TrainingDB;
GO

-- That should list Query Store system views such as:

SELECT TOP 10
    name,
    object_id,
    type_desc
FROM sys.system_views
WHERE name LIKE 'query_store%'
ORDER BY name;

-- Query Store system views such as:
-- query_store_query
-- query_store_query_text
-- query_store_plan
-- query_store_runtime_stats
-- query_store_runtime_stats_interval
-- query_store_wait_stats

USE TrainingDB;
GO

SELECT TOP 10 *
FROM sys.query_store_query_text;

USE TrainingDB;
GO

SELECT TOP 10 *
FROM sys.objects;

SELECT COUNT(*)
FROM sys.objects;

SELECT name, type_desc
FROM sys.objects
WHERE type = 'U';
GO

