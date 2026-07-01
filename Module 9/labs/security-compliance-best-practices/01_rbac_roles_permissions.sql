USE TrainingDB;
GO

-- Module 9 continues with the TrainingDB objects created in earlier labs.
-- RBAC gives access to job roles, then people or service accounts join those roles.
IF DATABASE_PRINCIPAL_ID('DataAnalystRole') IS NULL
    CREATE ROLE DataAnalystRole;
GO

IF DATABASE_PRINCIPAL_ID('ETLServiceRole') IS NULL
    CREATE ROLE ETLServiceRole;
GO

IF DATABASE_PRINCIPAL_ID('AuditReviewerRole') IS NULL
    CREATE ROLE AuditReviewerRole;
GO

-- Example domain accounts. These statements run only if the users exist locally.
IF DATABASE_PRINCIPAL_ID('CBL\analyst01') IS NOT NULL
    ALTER ROLE DataAnalystRole ADD MEMBER [CBL\analyst01];

IF DATABASE_PRINCIPAL_ID('CBL\svc_python_etl') IS NOT NULL
    ALTER ROLE ETLServiceRole ADD MEMBER [CBL\svc_python_etl];

IF DATABASE_PRINCIPAL_ID('CBL\audit01') IS NOT NULL
    ALTER ROLE AuditReviewerRole ADD MEMBER [CBL\audit01];
GO

-- Analysts read reporting data and exchange rates from Module 2 and Module 6.
IF OBJECT_ID('m2.FxRates', 'U') IS NOT NULL
    GRANT SELECT ON m2.FxRates TO DataAnalystRole;

IF OBJECT_ID('m6.WEOCountryMacro', 'U') IS NOT NULL
    GRANT SELECT ON m6.WEOCountryMacro TO DataAnalystRole;

-- ETL service accounts load only the staging table they need.
IF OBJECT_ID('m2.StagingTransactions', 'U') IS NOT NULL
    GRANT INSERT ON m2.StagingTransactions TO ETLServiceRole;

-- Auditors read evidence, not operational source tables.
IF OBJECT_ID('m6.ReportDistributionAudit', 'U') IS NOT NULL
    GRANT SELECT ON m6.ReportDistributionAudit TO AuditReviewerRole;
GO
