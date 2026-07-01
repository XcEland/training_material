USE TrainingDB;
GO

-- Module 8 logged Python workflow events. Module 9 adds a security audit schema.
IF SCHEMA_ID('audit') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA audit');
END;
GO

IF OBJECT_ID('audit.ProcessAuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE audit.ProcessAuditLog
    (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        ProcessName VARCHAR(100) NOT NULL,
        JobID VARCHAR(50) NULL,
        ActionType VARCHAR(50) NOT NULL,
        ObjectName VARCHAR(200) NULL,
        Status VARCHAR(20) NOT NULL,
        RowsAffected INT NULL,
        PerformedBy VARCHAR(100) NULL,
        PerformedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        Details NVARCHAR(MAX) NULL
    );
END;
GO

-- Controlled procedure: load validated Module 2 staging rows and write audit evidence.
CREATE OR ALTER PROCEDURE m2.usp_LoadValidatedTransactions
    @BatchID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO audit.ProcessAuditLog
            (ProcessName, JobID, ActionType, ObjectName, Status, PerformedBy, Details)
        VALUES
            ('Validated Transaction Load', @BatchID, 'START',
             'm2.usp_LoadValidatedTransactions', 'Started', SUSER_SNAME(),
             'Load process started');

        -- Main load logic would move rows from m2.StagingTransactions.

        INSERT INTO audit.ProcessAuditLog
            (ProcessName, JobID, ActionType, ObjectName, Status, PerformedBy, Details)
        VALUES
            ('Validated Transaction Load', @BatchID, 'COMPLETE',
             'm2.usp_LoadValidatedTransactions', 'Success', SUSER_SNAME(),
             'Load process completed');
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        INSERT INTO audit.ProcessAuditLog
            (ProcessName, JobID, ActionType, ObjectName, Status, PerformedBy, Details)
        VALUES
            ('Validated Transaction Load', @BatchID, 'ERROR',
             'm2.usp_LoadValidatedTransactions', 'Failed', SUSER_SNAME(),
             @ErrorMessage);

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO
