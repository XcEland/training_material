-- ============================================================
-- MODULE 3 LAB
-- FILE 04: TRIGGERS FOR AUDIT AND BUSINESS RULES
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- A trigger runs automatically when a data change happens on a table.
-- The inserted pseudo-table contains new values for INSERT and UPDATE.
-- The deleted pseudo-table contains old values for UPDATE and DELETE.
-- This file starts with a simple insert logging trigger, then moves to audit and business rules.

-- 1. Basic trigger: log every staging insert.
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

-- 2. Demonstrate the basic insert logging trigger.
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

-- 3. Audit trigger for update and delete activity.
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

-- 4. Business-rule trigger.
-- This trigger blocks invalid financial values before they remain in the table.
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

-- 5. Demonstrate the audit trigger.
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

-- 6. Demonstrate business-rule trigger with a handled error.
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

SELECT TOP 5
    ErrorTime,
    ProcedureName,
    ErrorNumber,
    ErrorMessage
FROM m3.ErrorLog
ORDER BY ErrorLogID DESC;
GO
