-- ============================================================
-- MODULE 6 LAB
-- FILE 01: SETUP WEO MONTHLY REPORTING TABLES
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm6')
BEGIN
    EXEC('CREATE SCHEMA m6');
END;
GO

IF OBJECT_ID('m6.ReportDistributionAudit', 'U') IS NOT NULL DROP TABLE m6.ReportDistributionAudit;
IF OBJECT_ID('m6.MonthlyReportRunLog', 'U') IS NOT NULL DROP TABLE m6.MonthlyReportRunLog;
IF OBJECT_ID('m6.WEOCommodityIndicatorLong', 'U') IS NOT NULL DROP TABLE m6.WEOCommodityIndicatorLong;
IF OBJECT_ID('m6.WEOGroupIndicatorLong', 'U') IS NOT NULL DROP TABLE m6.WEOGroupIndicatorLong;
IF OBJECT_ID('m6.WEOCountryMacro', 'U') IS NOT NULL DROP TABLE m6.WEOCountryMacro;
GO

CREATE TABLE m6.WEOCountryMacro (
    country_id VARCHAR(20) NOT NULL,
    country NVARCHAR(160) NOT NULL,
    year INT NOT NULL,
    gdp_growth_pct FLOAT NULL,
    inflation_pct FLOAT NULL,
    unemployment_rate FLOAT NULL,
    current_account_pct_gdp FLOAT NULL,
    government_debt_pct_gdp FLOAT NULL,
    gdp_per_capita_usd FLOAT NULL,
    investment_pct_gdp FLOAT NULL,
    savings_pct_gdp FLOAT NULL,
    export_volume_growth_pct FLOAT NULL,
    import_volume_growth_pct FLOAT NULL,
    economic_group NVARCHAR(120) NULL,
    is_sub_saharan_africa INT NOT NULL,
    source_publication_date VARCHAR(40) NULL,
    source_workbook NVARCHAR(500) NULL,
    loaded_at VARCHAR(40) NULL
);
GO

CREATE TABLE m6.WEOGroupIndicatorLong (
    country_id VARCHAR(20) NOT NULL,
    country NVARCHAR(160) NOT NULL,
    indicator_id VARCHAR(40) NOT NULL,
    indicator NVARCHAR(500) NULL,
    unit NVARCHAR(80) NULL,
    year INT NOT NULL,
    value FLOAT NULL,
    source_sheet VARCHAR(60) NULL,
    source_publication_date VARCHAR(40) NULL,
    source_workbook NVARCHAR(500) NULL,
    loaded_at VARCHAR(40) NULL
);
GO

CREATE TABLE m6.WEOCommodityIndicatorLong (
    country_id VARCHAR(20) NOT NULL,
    country NVARCHAR(160) NOT NULL,
    indicator_id VARCHAR(40) NOT NULL,
    indicator NVARCHAR(500) NULL,
    unit NVARCHAR(80) NULL,
    year INT NOT NULL,
    value FLOAT NULL,
    source_sheet VARCHAR(60) NULL,
    source_publication_date VARCHAR(40) NULL,
    source_workbook NVARCHAR(500) NULL,
    loaded_at VARCHAR(40) NULL
);
GO

CREATE TABLE m6.MonthlyReportRunLog (
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt DATETIME2 NULL,
    ReportMonth VARCHAR(7) NOT NULL,
    Status VARCHAR(30) NOT NULL,
    OutputPath NVARCHAR(1000) NULL,
    EmailStatus VARCHAR(40) NULL,
    Message NVARCHAR(1000) NULL
);
GO

CREATE TABLE m6.ReportDistributionAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    RunID INT NULL,
    ReportMonth VARCHAR(7) NOT NULL,
    RecipientEmail VARCHAR(200) NOT NULL,
    RecipientGroup VARCHAR(100) NOT NULL,
    DeliveryStatus VARCHAR(40) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (RunID) REFERENCES m6.MonthlyReportRunLog(RunID)
);
GO

-- The Python pipeline loads the WEO Excel workbook into these tables.
-- Example extraction query used by the reports:
SELECT TOP (10)
    country,
    year,
    gdp_growth_pct,
    inflation_pct,
    economic_group
FROM m6.WEOCountryMacro
WHERE year = 2026
ORDER BY gdp_growth_pct DESC;
GO
