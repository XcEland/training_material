-- ============================================================
-- MODULE 2 LAB
-- FILE 06: EXECUTION PLANS DEMO
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- Execution plans show how SQL Server chooses to access, join, sort, and return data.
-- Statistics output helps compare logical reads and elapsed time.
-- Compare Table Scan, Index Scan, Index Seek, Sort, Nested Loops, Hash Match, and Key Lookup operators.
-- Focus on logical reads first, then CPU time and elapsed time.

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_TransactionDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_TransactionDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_DateCurrency'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_DateCurrency ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_CurrencyDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_CurrencyDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_AccountDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    DROP INDEX IX_M2_FinancialTransactions_AccountDate ON m2.FinancialTransactions;
END;
GO

IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_Accounts_Counterparty'
      AND object_id = OBJECT_ID('m2.Accounts')
)
BEGIN
    DROP INDEX IX_M2_Accounts_Counterparty ON m2.Accounts;
END;
GO

SELECT
    COUNT(*) AS FinancialTransactionRows
FROM m2.FinancialTransactions;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- 1. Simple selective query.
-- One table, a normal WHERE clause, and a small result set.
SELECT TOP 20
    TransactionID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
FROM m2.FinancialTransactions
WHERE CurrencyCode = 'USD'
ORDER BY TransactionDate DESC;
GO

-- 2. Non-sargable filter.
-- YEAR() and MONTH() are applied to the column, so SQL Server has less chance to seek efficiently.
-- Compare reads and plan shape with the next query.
SELECT TOP 100
    TransactionID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
FROM m2.FinancialTransactions
WHERE YEAR(TransactionDate) = 2026
  AND MONTH(TransactionDate) = 6
  AND CurrencyCode = 'USD'
ORDER BY Amount DESC;
GO

-- 3. Sargable date range filter.
-- The date column is left unchanged; the range boundaries are on the constant side.
SELECT TOP 100
    TransactionID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD'
ORDER BY Amount DESC;
GO

-- 4. SELECT * versus selected columns.
-- SELECT * can read and return more data than the report needs.
SELECT TOP 50
    *
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD';
GO

SELECT TOP 50
    TransactionID,
    AccountID,
    TransactionDate,
    TransactionType,
    Amount,
    CurrencyCode,
    Status
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD';
GO

-- 5. Filter before joining large tables.
-- The CTE narrows the transaction rows before descriptive joins are applied.
WITH FilteredTransactions AS (
    SELECT
        TransactionID,
        AccountID,
        TransactionDate,
        Amount,
        CurrencyCode,
        Status
    FROM m2.FinancialTransactions
    WHERE TransactionDate >= '2026-06-01'
      AND TransactionDate < '2026-07-01'
      AND Status = 'Posted'
)
SELECT TOP 100
    cp.CounterpartyName,
    a.AccountNumber,
    ft.TransactionDate,
    ft.Amount,
    ft.CurrencyCode,
    ft.Status
FROM FilteredTransactions AS ft
INNER JOIN m2.Accounts AS a
    ON ft.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
ORDER BY ft.TransactionDate DESC;
GO

-- 6. Join plan example.
-- Inspect join operators and which tables are scanned or sought.
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

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
