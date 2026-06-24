-- ============================================================
-- MODULE 6 LAB
-- FILE 01: SETUP MONTHLY REPORTING DATASET
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
IF OBJECT_ID('m6.MonthlyFinancialIndicators', 'U') IS NOT NULL DROP TABLE m6.MonthlyFinancialIndicators;
GO

CREATE TABLE m6.MonthlyFinancialIndicators (
    IndicatorID INT IDENTITY(1,1) PRIMARY KEY,
    ReportMonth DATE NOT NULL,
    InstitutionCode VARCHAR(20) NOT NULL,
    InstitutionName VARCHAR(120) NOT NULL,
    InstitutionType VARCHAR(40) NOT NULL,
    Region VARCHAR(40) NOT NULL,
    TotalDepositsLSL DECIMAL(18,2) NOT NULL,
    TotalLoansLSL DECIMAL(18,2) NOT NULL,
    LiquidityRatio DECIMAL(9,4) NOT NULL,
    CapitalAdequacyRatio DECIMAL(9,4) NOT NULL,
    NplRatio DECIMAL(9,4) NOT NULL,
    TransactionValueLSL DECIMAL(18,2) NOT NULL,
    StressFlag BIT NOT NULL
);
GO

CREATE TABLE m6.MonthlyReportRunLog (
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt DATETIME2 NULL,
    ReportMonth DATE NOT NULL,
    Status VARCHAR(30) NOT NULL,
    OutputPath NVARCHAR(500) NULL,
    EmailStatus VARCHAR(40) NULL,
    Message NVARCHAR(1000) NULL
);
GO

CREATE TABLE m6.ReportDistributionAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    RunID INT NULL,
    ReportMonth DATE NOT NULL,
    RecipientEmail VARCHAR(200) NOT NULL,
    RecipientGroup VARCHAR(100) NOT NULL,
    DeliveryStatus VARCHAR(40) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (RunID) REFERENCES m6.MonthlyReportRunLog(RunID)
);
GO

INSERT INTO m6.MonthlyFinancialIndicators (
    ReportMonth,
    InstitutionCode,
    InstitutionName,
    InstitutionType,
    Region,
    TotalDepositsLSL,
    TotalLoansLSL,
    LiquidityRatio,
    CapitalAdequacyRatio,
    NplRatio,
    TransactionValueLSL,
    StressFlag
)
VALUES
    ('2026-04-01', 'CBL', 'Central Bank Liquidity Desk', 'Central Bank', 'Maseru', 958400000.00, 324800000.00, 0.3520, 0.2220, 0.0210, 35120000.00, 0),
    ('2026-04-01', 'MCB', 'Maseru Commercial Bank', 'Commercial Bank', 'Maseru', 642200000.00, 548900000.00, 0.2810, 0.1640, 0.0520, 23840000.00, 0),
    ('2026-04-01', 'LMB', 'Leribe Microfinance Bank', 'Microfinance', 'Leribe', 198700000.00, 184200000.00, 0.2240, 0.1310, 0.0860, 8240000.00, 1),
    ('2026-04-01', 'QFB', 'Quthing Finance Bank', 'Commercial Bank', 'Quthing', 292100000.00, 266700000.00, 0.2480, 0.1510, 0.0710, 11390000.00, 0),
    ('2026-04-01', 'BDB', 'Butha-Buthe Development Bank', 'Development Bank', 'Butha-Buthe', 348200000.00, 314600000.00, 0.2610, 0.1580, 0.0640, 13950000.00, 0),
    ('2026-04-01', 'MFI', 'Mafeteng Inclusion Finance', 'Microfinance', 'Mafeteng', 154300000.00, 149200000.00, 0.2110, 0.1210, 0.0940, 6720000.00, 1),

    ('2026-05-01', 'CBL', 'Central Bank Liquidity Desk', 'Central Bank', 'Maseru', 972000000.00, 331400000.00, 0.3490, 0.2240, 0.0220, 36750000.00, 0),
    ('2026-05-01', 'MCB', 'Maseru Commercial Bank', 'Commercial Bank', 'Maseru', 655900000.00, 559800000.00, 0.2760, 0.1630, 0.0550, 25200000.00, 0),
    ('2026-05-01', 'LMB', 'Leribe Microfinance Bank', 'Microfinance', 'Leribe', 204100000.00, 191800000.00, 0.2190, 0.1290, 0.0900, 8660000.00, 1),
    ('2026-05-01', 'QFB', 'Quthing Finance Bank', 'Commercial Bank', 'Quthing', 299400000.00, 273900000.00, 0.2440, 0.1490, 0.0740, 12150000.00, 0),
    ('2026-05-01', 'BDB', 'Butha-Buthe Development Bank', 'Development Bank', 'Butha-Buthe', 356800000.00, 322900000.00, 0.2580, 0.1560, 0.0670, 14670000.00, 0),
    ('2026-05-01', 'MFI', 'Mafeteng Inclusion Finance', 'Microfinance', 'Mafeteng', 160200000.00, 155400000.00, 0.2070, 0.1190, 0.0980, 7050000.00, 1),

    ('2026-06-01', 'CBL', 'Central Bank Liquidity Desk', 'Central Bank', 'Maseru', 984300000.00, 337800000.00, 0.3470, 0.2250, 0.0230, 38160000.00, 0),
    ('2026-06-01', 'MCB', 'Maseru Commercial Bank', 'Commercial Bank', 'Maseru', 668500000.00, 572600000.00, 0.2710, 0.1600, 0.0590, 26950000.00, 0),
    ('2026-06-01', 'LMB', 'Leribe Microfinance Bank', 'Microfinance', 'Leribe', 211900000.00, 199700000.00, 0.2140, 0.1260, 0.0950, 9180000.00, 1),
    ('2026-06-01', 'QFB', 'Quthing Finance Bank', 'Commercial Bank', 'Quthing', 306800000.00, 281300000.00, 0.2380, 0.1460, 0.0780, 12890000.00, 0),
    ('2026-06-01', 'BDB', 'Butha-Buthe Development Bank', 'Development Bank', 'Butha-Buthe', 365400000.00, 330500000.00, 0.2530, 0.1530, 0.0700, 15320000.00, 0),
    ('2026-06-01', 'MFI', 'Mafeteng Inclusion Finance', 'Microfinance', 'Mafeteng', 166700000.00, 162600000.00, 0.2020, 0.1160, 0.1040, 7440000.00, 1);
GO

SELECT
    ReportMonth,
    COUNT(*) AS InstitutionRows,
    SUM(CASE WHEN StressFlag = 1 THEN 1 ELSE 0 END) AS StressRows
FROM m6.MonthlyFinancialIndicators
GROUP BY ReportMonth
ORDER BY ReportMonth;
GO
