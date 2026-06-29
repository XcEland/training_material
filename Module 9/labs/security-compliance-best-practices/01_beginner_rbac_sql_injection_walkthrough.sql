/* =============================================================================
   Module 9 Beginner SQL Security Walkthrough
-------------------------------------------------------------------------------
   This file introduces three beginner ideas before the full SQL lab:

   1. Users should receive permissions through roles.
   2. Application scripts should execute approved procedures, not own tables.
   3. SQL text should not be built by joining user input into a string.
============================================================================= */

USE TrainingDB;
GO

IF SCHEMA_ID('m9') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA m9');
END;
GO

IF OBJECT_ID('m9.ReportAccessRegister', 'U') IS NULL
BEGIN
    CREATE TABLE m9.ReportAccessRegister
    (
        ReportAccessID INT IDENTITY(1,1) PRIMARY KEY,
        ReportName NVARCHAR(120) NOT NULL,
        AudienceGroup NVARCHAR(120) NOT NULL,
        Classification NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM m9.ReportAccessRegister)
BEGIN
    INSERT INTO m9.ReportAccessRegister (ReportName, AudienceGroup, Classification)
    VALUES
        ('WEO Macro Outlook Executive Brief', 'Executive Committee', 'Confidential'),
        ('Inflation Risk Monitoring Report', 'Monetary Policy and Research', 'Confidential'),
        ('Commodity Price Monitoring Brief', 'Markets and Research', 'Internal');
END;
GO

IF DATABASE_PRINCIPAL_ID('m9_report_reader') IS NULL
    CREATE ROLE m9_report_reader;
GO

IF DATABASE_PRINCIPAL_ID('m9_report_app_executor') IS NULL
    CREATE ROLE m9_report_app_executor;
GO

-- Beginner RBAC example:
-- Readers can select approved report metadata.
-- Application accounts execute stored procedures.
GRANT SELECT ON m9.ReportAccessRegister TO m9_report_reader;
GO

CREATE OR ALTER PROCEDURE m9.usp_GetReportAccessByAudience
    @AudienceGroup NVARCHAR(120)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ReportAccessID, ReportName, AudienceGroup, Classification
    FROM m9.ReportAccessRegister
    WHERE AudienceGroup = @AudienceGroup;
END;
GO

GRANT EXECUTE ON m9.usp_GetReportAccessByAudience TO m9_report_app_executor;
GO

-- Safe test call. The parameter value is data, not executable SQL text.
EXEC m9.usp_GetReportAccessByAudience @AudienceGroup = 'Executive Committee';
GO

-- Discussion prompt:
-- Why is this safer than letting every script connect as sa/db_owner and query
-- any table directly?
