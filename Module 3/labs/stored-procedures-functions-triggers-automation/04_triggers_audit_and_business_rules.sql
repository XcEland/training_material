-- ============================================================
-- MODULE 3 LAB
-- FILE 04: TRIGGERS FOR AUDIT AND BUSINESS RULES
-- ============================================================

USE TrainingDB;
GO

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

-- Demonstrate audit trigger.
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

-- Demonstrate business-rule trigger with a handled error.
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
