-- ============================================================
-- MODULE 2 LAB: ADVANCED T-SQL QUERY DESIGN AND OPTIMIZATION
-- FILE 01: SETUP FINANCIAL TRANSACTIONS DATASET
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm2')
BEGIN
    EXEC('CREATE SCHEMA m2');
END;
GO

IF OBJECT_ID('m2.OptimizationBenchmark', 'U') IS NOT NULL DROP TABLE m2.OptimizationBenchmark;
IF OBJECT_ID('m2.MonthlyTransactionSummary', 'U') IS NOT NULL DROP TABLE m2.MonthlyTransactionSummary;
IF OBJECT_ID('m2.TransactionAudit', 'U') IS NOT NULL DROP TABLE m2.TransactionAudit;
IF OBJECT_ID('m2.ErrorLog', 'U') IS NOT NULL DROP TABLE m2.ErrorLog;
IF OBJECT_ID('m2.StagingTransactions', 'U') IS NOT NULL DROP TABLE m2.StagingTransactions;
IF OBJECT_ID('m2.FinancialTransactions', 'U') IS NOT NULL DROP TABLE m2.FinancialTransactions;
IF OBJECT_ID('m2.FxRates', 'U') IS NOT NULL DROP TABLE m2.FxRates;
IF OBJECT_ID('m2.Accounts', 'U') IS NOT NULL DROP TABLE m2.Accounts;
IF OBJECT_ID('m2.Counterparties', 'U') IS NOT NULL DROP TABLE m2.Counterparties;
GO

CREATE TABLE m2.Counterparties (
    CounterpartyID INT IDENTITY(1,1) PRIMARY KEY,
    CounterpartyName VARCHAR(120) NOT NULL,
    Sector VARCHAR(50) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    RiskRating VARCHAR(20) NOT NULL
);
GO

CREATE TABLE m2.Accounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    AccountNumber VARCHAR(30) NOT NULL UNIQUE,
    CounterpartyID INT NOT NULL,
    AccountType VARCHAR(40) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL,
    CurrentBalance DECIMAL(18,2) NOT NULL DEFAULT 0,
    OpenedDate DATE NOT NULL,
    AccountStatus VARCHAR(20) NOT NULL DEFAULT 'Active',

    CONSTRAINT FK_M2_Accounts_Counterparties
        FOREIGN KEY (CounterpartyID)
        REFERENCES m2.Counterparties(CounterpartyID)
);
GO

CREATE TABLE m2.FxRates (
    CurrencyCode CHAR(3) NOT NULL,
    RateDate DATE NOT NULL,
    RateToLSL DECIMAL(18,6) NOT NULL,
    CONSTRAINT PK_M2_FxRates PRIMARY KEY (CurrencyCode, RateDate)
);
GO

CREATE TABLE m2.FinancialTransactions (
    TransactionID BIGINT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT NOT NULL,
    TransactionDate DATE NOT NULL,
    ValueDate DATE NOT NULL,
    TransactionType VARCHAR(30) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL,
    Channel VARCHAR(30) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    ReferenceCode VARCHAR(40) NOT NULL UNIQUE,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_M2_FinancialTransactions_Accounts
        FOREIGN KEY (AccountID)
        REFERENCES m2.Accounts(AccountID)
);
GO

CREATE TABLE m2.StagingTransactions (
    ReferenceCode VARCHAR(40) NOT NULL PRIMARY KEY,
    AccountNumber VARCHAR(30) NOT NULL,
    TransactionDate DATE NOT NULL,
    ValueDate DATE NOT NULL,
    TransactionType VARCHAR(30) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL,
    Channel VARCHAR(30) NOT NULL,
    Status VARCHAR(20) NOT NULL
);
GO

CREATE TABLE m2.ErrorLog (
    ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorTime DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ProcedureName VARCHAR(100) NULL,
    ErrorNumber INT NULL,
    ErrorMessage NVARCHAR(4000) NOT NULL
);
GO

CREATE TABLE m2.TransactionAudit (
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionID BIGINT NULL,
    ActionName VARCHAR(30) NOT NULL,
    OldStatus VARCHAR(20) NULL,
    NewStatus VARCHAR(20) NULL,
    OldAmount DECIMAL(18,2) NULL,
    NewAmount DECIMAL(18,2) NULL,
    ChangedBy SYSNAME NOT NULL DEFAULT SUSER_SNAME(),
    ChangedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

INSERT INTO m2.Counterparties (CounterpartyName, Sector, Country, RiskRating)
VALUES
    ('Maseru Commercial Bank', 'Commercial Bank', 'Lesotho', 'Low'),
    ('Leribe Microfinance', 'Microfinance', 'Lesotho', 'Medium'),
    ('Cape Settlement Bank', 'Commercial Bank', 'South Africa', 'Low'),
    ('Johannesburg Clearing House', 'Clearing House', 'South Africa', 'Low'),
    ('London Reserve Custodian', 'Custodian', 'United Kingdom', 'Low'),
    ('Frankfurt Treasury Desk', 'Treasury', 'Germany', 'Low'),
    ('Regional Payment Switch', 'Payment System', 'Lesotho', 'Medium'),
    ('Government Treasury Unit', 'Government', 'Lesotho', 'Low'),
    ('Cross Border Remittance Ltd', 'Money Transfer', 'South Africa', 'High'),
    ('Rome Correspondent Bank', 'Correspondent Bank', 'Italy', 'Medium');
GO

INSERT INTO m2.Accounts
    (AccountNumber, CounterpartyID, AccountType, CurrencyCode, CurrentBalance, OpenedDate, AccountStatus)
VALUES
    ('M2-LSL-0001', 1, 'Settlement', 'LSL', 1250000.00, '2025-01-02', 'Active'),
    ('M2-LSL-0002', 2, 'Settlement', 'LSL', 875000.00, '2025-01-03', 'Active'),
    ('M2-ZAR-0003', 3, 'Reserve', 'ZAR', 2300000.00, '2025-01-04', 'Active'),
    ('M2-ZAR-0004', 4, 'Clearing', 'ZAR', 540000.00, '2025-01-05', 'Active'),
    ('M2-GBP-0005', 5, 'Reserve', 'GBP', 950000.00, '2025-01-06', 'Active'),
    ('M2-EUR-0006', 6, 'Reserve', 'EUR', 780000.00, '2025-01-07', 'Active'),
    ('M2-LSL-0007', 7, 'Payment', 'LSL', 440000.00, '2025-01-08', 'Active'),
    ('M2-LSL-0008', 8, 'Government', 'LSL', 3100000.00, '2025-01-09', 'Active'),
    ('M2-ZAR-0009', 9, 'Remittance', 'ZAR', 120000.00, '2025-01-10', 'Active'),
    ('M2-EUR-0010', 10, 'Correspondent', 'EUR', 660000.00, '2025-01-11', 'Active'),
    ('M2-USD-0011', 5, 'Reserve', 'USD', 1880000.00, '2025-01-12', 'Active'),
    ('M2-USD-0012', 6, 'Treasury', 'USD', 990000.00, '2025-01-13', 'Active'),
    ('M2-LSL-0013', 1, 'Settlement', 'LSL', 620000.00, '2025-01-14', 'Active'),
    ('M2-ZAR-0014', 3, 'Reserve', 'ZAR', 430000.00, '2025-01-15', 'Active'),
    ('M2-GBP-0015', 5, 'Reserve', 'GBP', 350000.00, '2025-01-16', 'Active');
GO

;WITH dates AS (
    SELECT CAST('2026-01-01' AS DATE) AS RateDate
    UNION ALL
    SELECT DATEADD(DAY, 1, RateDate)
    FROM dates
    WHERE RateDate < '2026-06-30'
)
INSERT INTO m2.FxRates (CurrencyCode, RateDate, RateToLSL)
SELECT
    c.CurrencyCode,
    d.RateDate,
    CAST(c.BaseRate + ((DATEPART(DAYOFYEAR, d.RateDate) % 11) * c.StepRate) AS DECIMAL(18,6)) AS RateToLSL
FROM dates AS d
CROSS JOIN (
    VALUES
        ('LSL', 1.000000, 0.000000),
        ('ZAR', 1.000000, 0.000000),
        ('USD', 18.250000, 0.015000),
        ('EUR', 19.750000, 0.020000),
        ('GBP', 23.100000, 0.025000)
) AS c(CurrencyCode, BaseRate, StepRate)
OPTION (MAXRECURSION 200);
GO

;WITH n AS (
    SELECT TOP (30000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
),
prepared AS (
    SELECT
        rn,
        ((rn - 1) % 15) + 1 AS AccountID,
        DATEADD(DAY, -1 * (rn % 180), CAST('2026-06-30' AS DATE)) AS TransactionDate,
        CAST(100 + ((rn * 37) % 75000) AS DECIMAL(18,2)) AS Amount
    FROM n
)
INSERT INTO m2.FinancialTransactions
    (AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode)
SELECT
    p.AccountID,
    p.TransactionDate,
    DATEADD(DAY, CASE WHEN p.rn % 5 = 0 THEN 1 ELSE 0 END, p.TransactionDate) AS ValueDate,
    CASE
        WHEN p.rn % 4 = 0 THEN 'Withdrawal'
        WHEN p.rn % 4 = 1 THEN 'Deposit'
        WHEN p.rn % 4 = 2 THEN 'Transfer'
        ELSE 'FX Settlement'
    END AS TransactionType,
    p.Amount,
    a.CurrencyCode,
    CASE
        WHEN p.rn % 5 = 0 THEN 'Branch'
        WHEN p.rn % 5 = 1 THEN 'Online Banking'
        WHEN p.rn % 5 = 2 THEN 'Mobile Banking'
        WHEN p.rn % 5 = 3 THEN 'SWIFT'
        ELSE 'Clearing'
    END AS Channel,
    CASE
        WHEN p.rn % 29 = 0 THEN 'Failed'
        WHEN p.rn % 17 = 0 THEN 'Pending'
        ELSE 'Posted'
    END AS Status,
    CONCAT('M2-', RIGHT(CONCAT('000000', p.rn), 6)) AS ReferenceCode
FROM prepared AS p
INNER JOIN m2.Accounts AS a
    ON p.AccountID = a.AccountID;
GO

INSERT INTO m2.StagingTransactions
    (ReferenceCode, AccountNumber, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status)
VALUES
    ('M2-000010', 'M2-USD-0011', '2026-06-30', '2026-06-30', 'Deposit', 85000.00, 'USD', 'SWIFT', 'Posted'),
    ('M2-000020', 'M2-EUR-0006', '2026-06-30', '2026-06-30', 'FX Settlement', 42000.00, 'EUR', 'SWIFT', 'Posted'),
    ('M2-030001', 'M2-LSL-0001', '2026-06-30', '2026-06-30', 'Deposit', 15000.00, 'LSL', 'Branch', 'Posted'),
    ('M2-030002', 'M2-ZAR-0003', '2026-06-30', '2026-06-30', 'Transfer', 32000.00, 'ZAR', 'Clearing', 'Pending'),
    ('M2-030003', 'M2-GBP-0005', '2026-06-30', '2026-07-01', 'Withdrawal', 12000.00, 'GBP', 'Online Banking', 'Posted');
GO

SELECT 'Counterparties' AS TableName, COUNT(*) AS TotalRows FROM m2.Counterparties
UNION ALL
SELECT 'Accounts', COUNT(*) FROM m2.Accounts
UNION ALL
SELECT 'FxRates', COUNT(*) FROM m2.FxRates
UNION ALL
SELECT 'FinancialTransactions', COUNT(*) FROM m2.FinancialTransactions
UNION ALL
SELECT 'StagingTransactions', COUNT(*) FROM m2.StagingTransactions;
GO
