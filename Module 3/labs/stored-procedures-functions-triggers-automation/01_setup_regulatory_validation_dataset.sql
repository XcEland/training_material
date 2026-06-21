-- ============================================================
-- MODULE 3 LAB
-- FILE 01: SETUP REGULATORY VALIDATION DATASET
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm3')
BEGIN
    EXEC('CREATE SCHEMA m3');
END;
GO

DROP TRIGGER IF EXISTS m3.trg_RegulatorySubmissions_Audit;
DROP TRIGGER IF EXISTS m3.trg_RegulatorySubmissions_BusinessRules;
DROP TRIGGER IF EXISTS m3.trg_StagingRegulatorySubmissions_InsertLog;
GO

DROP PROCEDURE IF EXISTS m3.usp_CountRegulatorySubmissions;
DROP PROCEDURE IF EXISTS m3.usp_ListSubmissionsByInstitution;
DROP PROCEDURE IF EXISTS m3.usp_GetInstitutionSubmissionSummary;
DROP PROCEDURE IF EXISTS m3.usp_RunDataQualityChecks;
DROP PROCEDURE IF EXISTS m3.usp_LogProcedureExecution;
GO

DROP FUNCTION IF EXISTS m3.fn_CapitalAdequacyBand;
DROP FUNCTION IF EXISTS m3.fn_SubmissionsByPeriod;
GO

IF OBJECT_ID('m3.ValidationViolation', 'U') IS NOT NULL DROP TABLE m3.ValidationViolation;
IF OBJECT_ID('m3.ValidationRun', 'U') IS NOT NULL DROP TABLE m3.ValidationRun;
IF OBJECT_ID('m3.ValidationRule', 'U') IS NOT NULL DROP TABLE m3.ValidationRule;
IF OBJECT_ID('m3.AuditLog', 'U') IS NOT NULL DROP TABLE m3.AuditLog;
IF OBJECT_ID('m3.ErrorLog', 'U') IS NOT NULL DROP TABLE m3.ErrorLog;
IF OBJECT_ID('m3.ProcedureExecutionLog', 'U') IS NOT NULL DROP TABLE m3.ProcedureExecutionLog;
IF OBJECT_ID('m3.StagingRegulatorySubmissions', 'U') IS NOT NULL DROP TABLE m3.StagingRegulatorySubmissions;
IF OBJECT_ID('m3.RegulatorySubmissions', 'U') IS NOT NULL DROP TABLE m3.RegulatorySubmissions;
IF OBJECT_ID('m3.Institutions', 'U') IS NOT NULL DROP TABLE m3.Institutions;
GO

CREATE TABLE m3.Institutions (
    InstitutionCode VARCHAR(20) NOT NULL PRIMARY KEY,
    InstitutionName VARCHAR(120) NOT NULL,
    InstitutionType VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE m3.RegulatorySubmissions (
    SubmissionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    InstitutionCode VARCHAR(20) NOT NULL,
    ReportingPeriod DATE NOT NULL,
    ReportType VARCHAR(40) NOT NULL,
    TotalAssets DECIMAL(18,2) NOT NULL,
    TotalLiabilities DECIMAL(18,2) NOT NULL,
    CapitalAdequacyRatio DECIMAL(9,4) NULL,
    LiquidityCoverageRatio DECIMAL(9,4) NULL,
    SubmissionStatus VARCHAR(20) NOT NULL DEFAULT 'Received',
    SubmittedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_M3_RegulatorySubmissions_Institutions
        FOREIGN KEY (InstitutionCode)
        REFERENCES m3.Institutions(InstitutionCode)
);
GO

CREATE TABLE m3.StagingRegulatorySubmissions (
    SubmissionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    InstitutionCode VARCHAR(20) NULL,
    ReportingPeriod DATE NULL,
    ReportType VARCHAR(40) NULL,
    TotalAssets DECIMAL(18,2) NULL,
    TotalLiabilities DECIMAL(18,2) NULL,
    CapitalAdequacyRatio DECIMAL(9,4) NULL,
    LiquidityCoverageRatio DECIMAL(9,4) NULL,
    SubmissionStatus VARCHAR(20) NULL,
    SubmittedAt DATETIME2 NULL
);
GO

CREATE TABLE m3.ProcedureExecutionLog (
    ExecutionLogID INT IDENTITY(1,1) PRIMARY KEY,
    ProcedureName SYSNAME NOT NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    EndedAt DATETIME2 NULL,
    Status VARCHAR(20) NOT NULL,
    RowsAffected INT NULL,
    Message NVARCHAR(1000) NULL
);
GO

CREATE TABLE m3.ErrorLog (
    ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorTime DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ProcedureName SYSNAME NULL,
    ErrorNumber INT NULL,
    ErrorSeverity INT NULL,
    ErrorState INT NULL,
    ErrorLine INT NULL,
    ErrorMessage NVARCHAR(4000) NOT NULL
);
GO

CREATE TABLE m3.AuditLog (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TableName SYSNAME NOT NULL,
    OperationType VARCHAR(20) NOT NULL,
    PrimaryKeyValue VARCHAR(50) NULL,
    ColumnName SYSNAME NULL,
    OldValue NVARCHAR(4000) NULL,
    NewValue NVARCHAR(4000) NULL,
    ChangedBy SYSNAME NOT NULL DEFAULT SUSER_SNAME(),
    ChangedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE m3.ValidationRule (
    RuleID INT IDENTITY(1,1) PRIMARY KEY,
    RuleSetName VARCHAR(50) NOT NULL,
    TargetSchema SYSNAME NOT NULL,
    TargetTable SYSNAME NOT NULL,
    RuleName VARCHAR(120) NOT NULL,
    ColumnName SYSNAME NOT NULL,
    RuleType VARCHAR(30) NOT NULL,
    MinNumericValue DECIMAL(18,4) NULL,
    MaxNumericValue DECIMAL(18,4) NULL,
    Severity VARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE m3.ValidationRun (
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    RuleSetName VARCHAR(50) NOT NULL,
    TargetSchema SYSNAME NOT NULL,
    TargetTable SYSNAME NOT NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt DATETIME2 NULL,
    Status VARCHAR(20) NOT NULL,
    TotalViolations INT NOT NULL DEFAULT 0,
    ExecutedBy SYSNAME NOT NULL DEFAULT SUSER_SNAME()
);
GO

CREATE TABLE m3.ValidationViolation (
    ViolationID INT IDENTITY(1,1) PRIMARY KEY,
    RunID INT NOT NULL,
    RuleID INT NOT NULL,
    SourceKey VARCHAR(50) NULL,
    Severity VARCHAR(20) NOT NULL,
    ViolationMessage NVARCHAR(1000) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_M3_ValidationViolation_Run
        FOREIGN KEY (RunID)
        REFERENCES m3.ValidationRun(RunID),

    CONSTRAINT FK_M3_ValidationViolation_Rule
        FOREIGN KEY (RuleID)
        REFERENCES m3.ValidationRule(RuleID)
);
GO

INSERT INTO m3.Institutions
    (InstitutionCode, InstitutionName, InstitutionType, Country)
VALUES
    ('CBL', 'Central Bank of Lesotho', 'Central Bank', 'Lesotho'),
    ('MCB', 'Maseru Commercial Bank', 'Commercial Bank', 'Lesotho'),
    ('LMB', 'Leribe Microfinance Bank', 'Microfinance', 'Lesotho'),
    ('CPS', 'Cape Payment Services', 'Payment Service Provider', 'South Africa'),
    ('RCH', 'Regional Clearing House', 'Clearing House', 'South Africa');
GO

INSERT INTO m3.RegulatorySubmissions
    (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus)
VALUES
    ('MCB', '2026-01-31', 'Monthly Prudential', 125000000.00, 98000000.00, 16.5000, 132.4000, 'Validated'),
    ('MCB', '2026-02-28', 'Monthly Prudential', 128500000.00, 100200000.00, 15.9000, 128.1000, 'Validated'),
    ('LMB', '2026-01-31', 'Monthly Prudential', 32000000.00, 25100000.00, 13.2500, 118.7500, 'Validated'),
    ('LMB', '2026-02-28', 'Monthly Prudential', 34100000.00, 26800000.00, 12.9000, 114.3000, 'Received'),
    ('CPS', '2026-01-31', 'Payment Systems', 54000000.00, 41000000.00, NULL, 104.5000, 'Validated'),
    ('RCH', '2026-01-31', 'Clearing House', 76000000.00, 60000000.00, NULL, 121.2000, 'Received');
GO

-- Staging rows intentionally include data quality issues.
INSERT INTO m3.StagingRegulatorySubmissions
    (InstitutionCode, ReportingPeriod, ReportType, TotalAssets, TotalLiabilities, CapitalAdequacyRatio, LiquidityCoverageRatio, SubmissionStatus, SubmittedAt)
VALUES
    ('MCB', '2026-03-31', 'Monthly Prudential', 130000000.00, 101000000.00, 16.1000, 127.0000, 'Received', SYSUTCDATETIME()),
    ('LMB', '2026-03-31', 'Monthly Prudential', 35000000.00, 27900000.00, 11.7000, 109.6000, 'Received', SYSUTCDATETIME()),
    (NULL, '2026-03-31', 'Monthly Prudential', 25000000.00, 21000000.00, 14.2000, 111.0000, 'Received', SYSUTCDATETIME()),
    ('BADBANK', '2026-03-31', 'Monthly Prudential', 12000000.00, 9000000.00, 18.0000, 130.0000, 'Received', SYSUTCDATETIME()),
    ('MCB', NULL, 'Monthly Prudential', 125000000.00, 99000000.00, 15.0000, 120.0000, 'Received', SYSUTCDATETIME()),
    ('LMB', '2026-03-31', 'Monthly Prudential', -100.00, 50000.00, 9.5000, 98.0000, 'Received', SYSUTCDATETIME()),
    ('CPS', '2026-03-31', 'Payment Systems', 58000000.00, 42000000.00, NULL, 95.0000, 'Unknown', SYSUTCDATETIME());
GO

INSERT INTO m3.ValidationRule
    (RuleSetName, TargetSchema, TargetTable, RuleName, ColumnName, RuleType, MinNumericValue, MaxNumericValue, Severity)
VALUES
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Institution code is required', 'InstitutionCode', 'NOT_NULL', NULL, NULL, 'High'),
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Reporting period is required', 'ReportingPeriod', 'NOT_NULL', NULL, NULL, 'High'),
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Total assets must be non-negative', 'TotalAssets', 'MIN_VALUE', 0, NULL, 'High'),
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Capital adequacy should be at least 10 percent', 'CapitalAdequacyRatio', 'MIN_VALUE', 10, NULL, 'Medium'),
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Liquidity coverage should be at least 100 percent', 'LiquidityCoverageRatio', 'MIN_VALUE', 100, NULL, 'Medium'),
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Submission status must be recognised', 'SubmissionStatus', 'STATUS_IN', NULL, NULL, 'Medium'),
    ('RegulatorySubmissionBasic', 'm3', 'StagingRegulatorySubmissions', 'Institution code must exist in reference table', 'InstitutionCode', 'FK_INSTITUTION', NULL, NULL, 'High');
GO

SELECT 'Institutions' AS TableName, COUNT(*) AS TotalRows FROM m3.Institutions
UNION ALL
SELECT 'RegulatorySubmissions', COUNT(*) FROM m3.RegulatorySubmissions
UNION ALL
SELECT 'StagingRegulatorySubmissions', COUNT(*) FROM m3.StagingRegulatorySubmissions
UNION ALL
SELECT 'ValidationRule', COUNT(*) FROM m3.ValidationRule;
GO
