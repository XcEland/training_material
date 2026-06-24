-- ============================================================
-- MODULE 3 LAB
-- FILE 04: TRIGGERS FOR AUDIT AND BUSINESS RULES
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A trigger runs automatically when a data change happens on a table.
-- DML triggers respond to INSERT, UPDATE, and DELETE operations.
-- SQL Server does not use "CREATE" for row-level data changes; CREATE is a DDL operation.
-- DDL triggers for CREATE/ALTER/DROP objects are a separate advanced topic.
-- The inserted pseudo-table contains new values for INSERT and UPDATE.
-- The deleted pseudo-table contains old values for UPDATE and DELETE.
-- This file starts with a simple insert logging trigger, then moves to audit and business rules.

-- Basic trigger structure:
-- CREATE TRIGGER TriggerName
-- ON TableName
-- AFTER INSERT, UPDATE, DELETE
-- AS
-- BEGIN
--     SQL statements go here.
-- END;

-- ============================================================
-- 1. BEGINNER EXAMPLE: EMPLOYEE INSERT LOG
-- ============================================================

-- This is the simple pattern:
-- Step 1: create a log table.
-- Step 2: create a trigger on the main table.
-- Step 3: insert data into the main table.
-- Step 4: check that the trigger wrote to the log table.

-- Clean up the beginner demo objects so this lab can be rerun.
DROP TRIGGER IF EXISTS m3.trg_AfterInsertEmployee;
DROP TABLE IF EXISTS m3.EmployeeLogs;
DROP TABLE IF EXISTS m3.Employees;
GO

-- Step 1: Create the main demo table.
CREATE TABLE m3.Employees (
    EmployeeID INT NOT NULL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    HireDate DATE NOT NULL,
    Gender CHAR(1) NOT NULL,
    Salary DECIMAL(18,2) NOT NULL,
    ManagerID INT NULL
);
GO

-- Step 2: Create the log table.
-- The trigger will write one row here for each inserted employee.
CREATE TABLE m3.EmployeeLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT,
    LogMessage VARCHAR(255),
    LogDate DATE
);
GO

-- Step 3: Create a trigger on the Employees table.
-- AFTER INSERT means this trigger runs after a new employee row is inserted.
-- inserted is a special trigger table that contains the new rows.
CREATE TRIGGER m3.trg_AfterInsertEmployee
ON m3.Employees
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO m3.EmployeeLogs
        (EmployeeID, LogMessage, LogDate)
    SELECT
        EmployeeID,
        'New Employee Added = ' + CAST(EmployeeID AS VARCHAR(20)),
        GETDATE()
    FROM inserted;
END;
GO

-- Step 4: Insert a new employee.
-- This INSERT automatically fires m3.trg_AfterInsertEmployee.
INSERT INTO m3.Employees
    (EmployeeID, FirstName, LastName, Department, HireDate, Gender, Salary, ManagerID)
VALUES
    (6, 'Maria', 'Doe', 'HR', '1988-01-12', 'F', 80000.00, 3);
GO

-- Step 5: Check the log table.
-- If the trigger worked, there should be one log row for EmployeeID = 6.
SELECT
    LogID,
    EmployeeID,
    LogMessage,
    LogDate
FROM m3.EmployeeLogs;
GO

-- ============================================================
-- 2. MODULE 3 EXAMPLE: LOG EVERY STAGING INSERT
-- ============================================================

-- Basic trigger: log every staging insert.
-- This is the simplest trigger pattern: after a row is inserted, write a log row.
CREATE OR ALTER TRIGGER m3.trg_StagingRegulatorySubmissions_InsertLog
ON m3.StagingRegulatorySubmissions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO m3.AuditLog
        (TableName, OperationType, PrimaryKeyValue, ColumnName, OldValue, NewValue)
    SELECT
        'm3.StagingRegulatorySubmissions',
        'INSERT',
        CAST(i.SubmissionID AS VARCHAR(50)),
        'SubmissionID',
        NULL,
        CAST(i.SubmissionID AS NVARCHAR(4000))
    FROM inserted AS i;
END;
GO

-- 3. Demonstrate the staging insert logging trigger.
-- The temporary row is removed after the log entry is created.
INSERT INTO m3.StagingRegulatorySubmissions
    (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt)
VALUES
    ('AUDITDEMO', '2026-04-30', 'Audit Trigger Demo', 1000.00, 500.00, 12.0000, 105.0000, 'Received', SYSUTCDATETIME());
GO

SELECT TOP 5
    AuditID,
    TableName,
    OperationType,
    PrimaryKeyValue,
    ColumnName,
    OldValue,
    NewValue,
    ChangedAt
FROM m3.AuditLog
WHERE TableName = 'm3.StagingRegulatorySubmissions'
ORDER BY AuditID DESC;
GO

DELETE FROM m3.StagingRegulatorySubmissions
WHERE InstitutionCode = 'AUDITDEMO'
  AND ReportType = 'Audit Trigger Demo';
GO

-- ============================================================
-- 4. DATA VALIDATION TRIGGER
-- ============================================================

-- Data validation trigger:
-- This checks new staging rows as they arrive.
-- If required fields are missing, negative values are sent, or status is invalid,
-- the trigger rejects the INSERT or UPDATE.
CREATE OR ALTER TRIGGER m3.trg_StagingRegulatorySubmissions_DataValidation
ON m3.StagingRegulatorySubmissions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE InstitutionCode IS NULL
           OR ReportingPeriod IS NULL
           OR ReportType IS NULL
    )
    BEGIN
        THROW 51010, 'Staging validation failed: institution code, reporting period, and report type are required.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE TotalAssets < 0
           OR TotalLiabilities < 0
    )
    BEGIN
        THROW 51011, 'Staging validation failed: total assets and total liabilities cannot be negative.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE SubmissionStatus IS NOT NULL
          AND SubmissionStatus NOT IN ('Received', 'Validated', 'Rejected', 'Submitted')
    )
    BEGIN
        THROW 51012, 'Staging validation failed: submission status must be Received, Validated, Rejected, or Submitted.', 1;
    END;
END;
GO

-- Demonstrate the data validation trigger with a handled error.
-- This row is missing InstitutionCode, so the trigger blocks it.
BEGIN TRY
    INSERT INTO m3.StagingRegulatorySubmissions
        (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt)
    VALUES
        (NULL, '2026-04-30', 'Monthly Prudential', 1000.00, 500.00, 12.0000, 105.0000, 'Received', SYSUTCDATETIME());
END TRY
BEGIN CATCH
    INSERT INTO m3.ErrorLog
        (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
    VALUES
        ('m3.trg_StagingRegulatorySubmissions_DataValidation demo', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

    SELECT
        'Trigger blocked invalid staging row' AS Result,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Demonstrate the same data validation trigger on UPDATE.
-- This first inserts a valid temporary row, then tries to update it to an invalid status.
INSERT INTO m3.StagingRegulatorySubmissions
    (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt)
VALUES
    ('MCB', '2026-04-30', 'Update Validation Demo', 1000.00, 500.00, 12.0000, 105.0000, 'Received', SYSUTCDATETIME());
GO

BEGIN TRY
    UPDATE m3.StagingRegulatorySubmissions
    SET SubmissionStatus = 'Unknown'
    WHERE InstitutionCode = 'MCB'
      AND ReportType = 'Update Validation Demo';
END TRY
BEGIN CATCH
    INSERT INTO m3.ErrorLog
        (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
    VALUES
        ('m3.trg_StagingRegulatorySubmissions_DataValidation update demo', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

    SELECT
        'Trigger blocked invalid staging update' AS Result,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

DELETE FROM m3.StagingRegulatorySubmissions
WHERE InstitutionCode = 'MCB'
  AND ReportType = 'Update Validation Demo';
GO

-- ============================================================
-- 5. AUDIT TRAIL TRIGGER
-- ============================================================

-- Audit trigger for update and delete activity.
-- This trigger records selected old and new values from RegulatorySubmissions.
CREATE OR ALTER TRIGGER m3.trg_RegulatorySubmissions_Audit
ON m3.RegulatorySubmissions
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO m3.AuditLog
        (TableName, OperationType, PrimaryKeyValue, ColumnName, OldValue, NewValue)
    SELECT
        'm3.RegulatorySubmissions',
        CASE WHEN i.SubmissionID IS NULL THEN 'DELETE' ELSE 'UPDATE' END,
        CAST(d.SubmissionID AS VARCHAR(50)),
        'SubmissionStatus',
        d.SubmissionStatus,
        i.SubmissionStatus
    FROM deleted AS d
    LEFT JOIN inserted AS i
        ON d.SubmissionID = i.SubmissionID
    WHERE i.SubmissionID IS NULL
       OR ISNULL(d.SubmissionStatus, '') <> ISNULL(i.SubmissionStatus, '');

    INSERT INTO m3.AuditLog
        (TableName, OperationType, PrimaryKeyValue, ColumnName, OldValue, NewValue)
    SELECT
        'm3.RegulatorySubmissions',
        'UPDATE',
        CAST(d.SubmissionID AS VARCHAR(50)),
        'TotalAssets',
        CONVERT(VARCHAR(50), d.TotalAssets),
        CONVERT(VARCHAR(50), i.TotalAssets)
    FROM deleted AS d
    INNER JOIN inserted AS i
        ON d.SubmissionID = i.SubmissionID
    WHERE d.TotalAssets <> i.TotalAssets;
END;
GO

-- ============================================================
-- 6. BUSINESS RULE TRIGGERS
-- ============================================================

-- Business-rule trigger for INSERT and UPDATE.
-- This blocks invalid financial values before they remain in the table.
CREATE OR ALTER TRIGGER m3.trg_RegulatorySubmissions_BusinessRules
ON m3.RegulatorySubmissions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE TotalAssets < 0
           OR TotalLiabilities < 0
    )
    BEGIN
        THROW 51001, 'Total assets and total liabilities cannot be negative.', 1;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE TotalLiabilities > TotalAssets
    )
    BEGIN
        THROW 51002, 'Total liabilities cannot exceed total assets for this lab rule.', 1;
    END;
END;
GO

-- Business-rule trigger for DELETE.
-- This protects validated regulatory submissions from accidental deletion.
CREATE OR ALTER TRIGGER m3.trg_RegulatorySubmissions_PreventValidatedDelete
ON m3.RegulatorySubmissions
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted
        WHERE SubmissionStatus = 'Validated'
    )
    BEGIN
        THROW 51003, 'Validated regulatory submissions cannot be deleted.', 1;
    END;
END;
GO

-- ============================================================
-- 7. DEMONSTRATE AUDIT TRAIL
-- ============================================================

-- Demonstrate the audit trigger.
UPDATE m3.RegulatorySubmissions
SET SubmissionStatus = 'Validated'
WHERE SubmissionID = 4;
GO

SELECT TOP 10
    AuditID,
    TableName,
    OperationType,
    PrimaryKeyValue,
    ColumnName,
    OldValue,
    NewValue,
    ChangedBy,
    ChangedAt
FROM m3.AuditLog
ORDER BY AuditID DESC;
GO

-- Demonstrate DELETE audit with a temporary non-validated row.
-- The delete is allowed because the row is not Validated.
DECLARE @DeleteDemoSubmissionID INT;

INSERT INTO m3.RegulatorySubmissions
    (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus)
VALUES
    ('MCB', '2026-05-31', 'Delete Audit Demo', 1000.00, 500.00, 15.0000, 120.0000, 'Received');

SET @DeleteDemoSubmissionID = SCOPE_IDENTITY();

DELETE FROM m3.RegulatorySubmissions
WHERE SubmissionID = @DeleteDemoSubmissionID;

SELECT TOP 10
    AuditID,
    TableName,
    OperationType,
    PrimaryKeyValue,
    ColumnName,
    OldValue,
    NewValue,
    ChangedAt
FROM m3.AuditLog
WHERE OperationType = 'DELETE'
ORDER BY AuditID DESC;
GO

-- ============================================================
-- 8. DEMONSTRATE BUSINESS RULE ENFORCEMENT
-- ============================================================

-- Demonstrate INSERT/UPDATE business-rule trigger with a handled error.
BEGIN TRY
    INSERT INTO m3.RegulatorySubmissions
        (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus)
    VALUES
        ('MCB', '2026-04-30', 'Monthly Prudential', -100.00, 50.00, 15.0000, 120.0000, 'Received');
END TRY
BEGIN CATCH
    INSERT INTO m3.ErrorLog
        (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
    VALUES
        ('m3.trg_RegulatorySubmissions_BusinessRules demo', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

    SELECT
        'Trigger blocked invalid insert' AS Result,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- Demonstrate DELETE business-rule trigger with a handled error.
-- SubmissionID = 1 is a validated row in the setup dataset.
BEGIN TRY
    DELETE FROM m3.RegulatorySubmissions
    WHERE SubmissionID = 1;
END TRY
BEGIN CATCH
    INSERT INTO m3.ErrorLog
        (ProcedureName, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage)
    VALUES
        ('m3.trg_RegulatorySubmissions_PreventValidatedDelete demo', ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE());

    SELECT
        'Trigger blocked delete' AS Result,
        ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

-- ============================================================
-- 9. REVIEW TRIGGER ERRORS
-- ============================================================

SELECT TOP 5
    ErrorTime,
    ProcedureName,
    ErrorNumber,
    ErrorMessage
FROM m3.ErrorLog
ORDER BY ErrorLogID DESC;
GO
