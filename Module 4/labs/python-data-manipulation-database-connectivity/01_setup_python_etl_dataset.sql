-- ============================================================
-- MODULE 4 LAB
-- FILE 01: SETUP PYTHON ETL DATASET
-- ============================================================

IF DB_ID('TrainingDB') IS NULL
BEGIN
    CREATE DATABASE TrainingDB;
END;
GO

USE TrainingDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm4')
BEGIN
    EXEC('CREATE SCHEMA m4');
END;
GO

IF OBJECT_ID('m4.CurrencySummary', 'U') IS NOT NULL DROP TABLE m4.CurrencySummary;
IF OBJECT_ID('m4.CleanFinancialTransactions', 'U') IS NOT NULL DROP TABLE m4.CleanFinancialTransactions;
IF OBJECT_ID('m4.EtlRunLog', 'U') IS NOT NULL DROP TABLE m4.EtlRunLog;
IF OBJECT_ID('m4.RawFinancialTransactions', 'U') IS NOT NULL DROP TABLE m4.RawFinancialTransactions;
GO

CREATE TABLE m4.RawFinancialTransactions (
    RawTransactionID INT IDENTITY(1,1) PRIMARY KEY,
    SourceSystem VARCHAR(40) NOT NULL,
    TransactionReference VARCHAR(50) NOT NULL,
    TransactionDateText VARCHAR(30) NULL,
    InstitutionCode VARCHAR(20) NULL,
    CounterpartyName VARCHAR(120) NULL,
    CurrencyCode VARCHAR(10) NULL,
    AmountText VARCHAR(40) NULL,
    TransactionType VARCHAR(30) NULL,
    Channel VARCHAR(30) NULL,
    LoadBatch VARCHAR(30) NOT NULL
);
GO

CREATE TABLE m4.CleanFinancialTransactions (
    CleanTransactionID INT IDENTITY(1,1) PRIMARY KEY,
    RawTransactionID INT NOT NULL,
    TransactionReference VARCHAR(50) NOT NULL,
    TransactionDate DATE NOT NULL,
    InstitutionCode VARCHAR(20) NOT NULL,
    CounterpartyName VARCHAR(120) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    AmountLSL DECIMAL(18,2) NOT NULL,
    TransactionType VARCHAR(30) NOT NULL,
    Channel VARCHAR(30) NOT NULL,
    AmountBand VARCHAR(20) NOT NULL,
    LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE m4.CurrencySummary (
    CurrencyCode CHAR(3) NOT NULL PRIMARY KEY,
    TransactionCount INT NOT NULL,
    TotalAmount DECIMAL(18,2) NOT NULL,
    TotalAmountLSL DECIMAL(18,2) NOT NULL,
    AverageAmount DECIMAL(18,2) NOT NULL,
    StandardDeviationAmount DECIMAL(18,2) NOT NULL,
    LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE m4.EtlRunLog (
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CompletedAt DATETIME2 NULL,
    Status VARCHAR(20) NOT NULL,
    ExtractedRows INT NOT NULL DEFAULT 0,
    CleanRows INT NOT NULL DEFAULT 0,
    RejectedRows INT NOT NULL DEFAULT 0,
    Message NVARCHAR(1000) NULL
);
GO

INSERT INTO m4.RawFinancialTransactions
    (SourceSystem, TransactionReference, TransactionDateText, InstitutionCode, CounterpartyName, CurrencyCode, AmountText, TransactionType, Channel, LoadBatch)
VALUES
    ('CoreBanking', 'M4-0001', '2026-06-01', 'MCB', 'Maseru Commercial Bank', 'LSL', '15000.00', 'Deposit', 'Branch', 'BATCH-202606'),
    ('CoreBanking', 'M4-0002', '01/06/2026', 'LMB', 'Leribe Microfinance Bank', 'lsl', '8200.50', 'Withdrawal', 'ATM', 'BATCH-202606'),
    ('Payments', 'M4-0003', '2026/06/02', 'CPS', 'Cape Payment Services', 'ZAR', '25000', 'Transfer', 'Clearing', 'BATCH-202606'),
    ('Treasury', 'M4-0004', '2026-06-03', 'CBL', 'Central Bank of Lesotho', 'USD', '100000.00', 'FX Settlement', 'SWIFT', 'BATCH-202606'),
    ('Treasury', 'M4-0005', '2026-06-04', 'RCH', 'Regional Clearing House', 'EUR', '45000.75', 'Transfer', 'Online Banking', 'BATCH-202606'),
    ('CoreBanking', 'M4-0006', NULL, 'MCB', 'Maseru Commercial Bank', 'LSL', '9100.00', 'Deposit', 'Branch', 'BATCH-202606'),
    ('CoreBanking', 'M4-0007', '2026-06-05', NULL, 'Unknown Institution', 'LSL', '700.00', 'Deposit', 'Mobile Banking', 'BATCH-202606'),
    ('Payments', 'M4-0008', '2026-06-06', 'CPS', 'Cape Payment Services', 'ZAR', NULL, 'Transfer', 'Clearing', 'BATCH-202606'),
    ('Treasury', 'M4-0009', '2026-06-07', 'CBL', 'Central Bank of Lesotho', 'GBP', '12000.00', 'Reserve Movement', 'SWIFT', 'BATCH-202606'),
    ('Treasury', 'M4-0010', '2026-06-08', 'CBL', 'Central Bank of Lesotho', 'usd', 'bad_amount', 'FX Settlement', 'SWIFT', 'BATCH-202606'),
    ('Payments', 'M4-0011', '2026-06-09', 'RCH', 'Regional Clearing House', 'EUR ', '30000.00', 'Transfer', 'Clearing', 'BATCH-202606'),
    ('CoreBanking', 'M4-0012', '2026-06-10', 'LMB', 'Leribe Microfinance Bank', 'LSL', '-500.00', 'Correction', 'Branch', 'BATCH-202606'),
    ('CoreBanking', 'M4-0013', '2026-06-11', 'MCB', 'Maseru Commercial Bank', 'LSL', '18500.00', 'Deposit', 'Mobile Banking', 'BATCH-202606'),
    ('Payments', 'M4-0014', '2026-06-12', 'CPS', 'Cape Payment Services', 'ZAR', '7600.00', NULL, 'POS', 'BATCH-202606'),
    ('Treasury', 'M4-0015', '2026-06-13', 'CBL', 'Central Bank of Lesotho', 'USD', '99000.25', 'FX Settlement', NULL, 'BATCH-202606');
GO

SELECT
    COUNT(*) AS RawRows
FROM m4.RawFinancialTransactions;
GO
