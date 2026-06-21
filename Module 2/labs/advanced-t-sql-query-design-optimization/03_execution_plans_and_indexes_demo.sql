-- ============================================================
-- MODULE 2 LAB
-- FILE 03: EXECUTION PLANS, STATISTICS, AND INDEXES DEMO
-- ============================================================

USE TrainingDB;
GO

-- Live demo:
-- In SSMS, enable Include Actual Execution Plan before running this file.
-- Watch for scans, sorts, row estimates, logical reads, and elapsed time.

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Poor pattern: SELECT *, functions on filter columns, and broad sorting.
-- Performance tip references:
-- - Avoid SELECT *
-- - Avoid functions on columns in WHERE
-- - Index columns used for filtering and joining
SELECT TOP 100
    *
FROM m2.FinancialTransactions
WHERE YEAR(TransactionDate) = 2026
  AND MONTH(TransactionDate) = 6
  AND CurrencyCode = 'USD'
ORDER BY Amount DESC;
GO

-- 2. Create indexes that support the Module 2 reporting patterns.
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_DateCurrency'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    CREATE INDEX IX_M2_FinancialTransactions_DateCurrency
    ON m2.FinancialTransactions (TransactionDate, CurrencyCode)
    INCLUDE (Amount, Status, AccountID, TransactionType, ReferenceCode);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_AccountDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    CREATE INDEX IX_M2_FinancialTransactions_AccountDate
    ON m2.FinancialTransactions (AccountID, TransactionDate)
    INCLUDE (Amount, CurrencyCode, Status);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_Accounts_Counterparty'
      AND object_id = OBJECT_ID('m2.Accounts')
)
BEGIN
    CREATE INDEX IX_M2_Accounts_Counterparty
    ON m2.Accounts (CounterpartyID)
    INCLUDE (AccountNumber, CurrencyCode, AccountType);
END;
GO

-- 3. Better pattern: selective columns and date range filter.
SELECT TOP 100
    TransactionID,
    AccountID,
    TransactionDate,
    TransactionType,
    Amount,
    CurrencyCode,
    Status,
    ReferenceCode
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD'
ORDER BY Amount DESC;
GO

-- 4. Join pattern supported by foreign-key and date indexes.
SELECT TOP 100
    cp.CounterpartyName,
    a.AccountNumber,
    t.TransactionDate,
    t.Amount,
    t.CurrencyCode,
    t.Status
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
WHERE t.TransactionDate >= '2026-06-01'
  AND t.TransactionDate < '2026-07-01'
  AND t.Status = 'Posted'
ORDER BY t.TransactionDate DESC;
GO

-- 5. Inspect index usage for Module 2 tables.
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    COALESCE(us.user_seeks, 0) AS UserSeeks,
    COALESCE(us.user_scans, 0) AS UserScans,
    COALESCE(us.user_lookups, 0) AS UserLookups,
    COALESCE(us.user_updates, 0) AS UserUpdates
FROM sys.indexes AS i
LEFT JOIN sys.dm_db_index_usage_stats AS us
    ON i.object_id = us.object_id
    AND i.index_id = us.index_id
    AND us.database_id = DB_ID()
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'm2'
  AND i.name IS NOT NULL
ORDER BY TableName, IndexName;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
