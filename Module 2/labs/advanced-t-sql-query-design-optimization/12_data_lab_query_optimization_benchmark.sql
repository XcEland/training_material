-- ============================================================
-- MODULE 2 DATA LAB
-- FILE 12: QUERY OPTIMIZATION BENCHMARK
-- ============================================================

USE TrainingDB;
GO

-- Use Messages for STATISTICS IO/TIME.
-- Use the XML result to compare execution plans.

-- ------------------------------------------------------------
-- Query 1 BEFORE: non-sargable date filter and SELECT *
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q1AFter;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT *
INTO #Q1Before
FROM m2.FinancialTransactions
WHERE YEAR(TransactionDate) = 2026
  AND MONTH(TransactionDate) = 6
  AND CurrencyCode = 'USD'
  AND Status = 'Posted';
GO

SELECT *
INTO #Q1AFter
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD'
  AND Status = 'Posted';
GO


SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Query 2 BEFORE: repeated correlated running-total subquery
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q2Before;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT TOP 500
    cp.CounterpartyName,
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionID,
    t.Amount,
    (
        SELECT SUM(t2.Amount)
        FROM m2.FinancialTransactions AS t2
        WHERE t2.AccountID = t.AccountID
          AND t2.Status = 'Posted'
          AND (
              t2.TransactionDate < t.TransactionDate
              OR (
                  t2.TransactionDate = t.TransactionDate
                  AND t2.TransactionID <= t.TransactionID
              )
          )
    ) AS RunningPostedAmount
INTO #Q2Before
FROM m2.FinancialTransactions AS t
INNER JOIN m2.Accounts AS a
    ON t.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
WHERE t.Status = 'Posted'
ORDER BY
    a.AccountNumber,
    t.TransactionDate,
    t.TransactionID;
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Query 3 BEFORE: filter after grouping
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q3Before;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT
    CurrencyCode,
    COUNT(*) AS PostedTransactionCount,
    SUM(Amount) AS PostedAmount
INTO #Q3Before
FROM m2.FinancialTransactions
GROUP BY
    CurrencyCode,
    Status
HAVING Status = 'Posted';
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Query 4 BEFORE: function on filtered column
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q4Before;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT TOP 500
    TransactionID,
    AccountID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
INTO #Q4Before
FROM m2.FinancialTransactions
WHERE UPPER(Status) = 'POSTED'
ORDER BY TransactionDate DESC;
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Improvement 1: rewrite inefficient queries
-- ------------------------------------------------------------
-- The AFTER examples below rewrite the inefficient parts:
-- - Query 1 changes YEAR/MONTH filters to a date range.
-- - Query 2 changes a correlated subquery to a window function.
-- - Query 3 moves Status filtering before GROUP BY.
-- - Query 4 removes UPPER() from the filtered column.

-- ------------------------------------------------------------
-- Improvement 2: add a proper index for common filters
-- ------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_StatusDate'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    CREATE INDEX IX_M2_FinancialTransactions_StatusDate
    ON m2.FinancialTransactions (Status, TransactionDate);
END;
GO

-- ------------------------------------------------------------
-- Improvement 3: use a covering index for Query 1 AFTER
-- ------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_Q1Covering'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    CREATE INDEX IX_M2_FinancialTransactions_Q1Covering
    ON m2.FinancialTransactions (TransactionDate, CurrencyCode, Status)
    INCLUDE (TransactionID, AccountID, TransactionType, Amount, ReferenceCode);
END;
GO

-- ------------------------------------------------------------
-- Query 1 AFTER: sargable date range and selected columns
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q1After;
GO

DROP TABLE IF EXISTS #Q1Before;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT *
INTO #Q1Before
FROM m2.FinancialTransactions
WHERE YEAR(TransactionDate) = 2026
  AND MONTH(TransactionDate) = 6
  AND CurrencyCode = 'USD'
  AND Status = 'Posted';
GO

SELECT
    TransactionID,
    AccountID,
    TransactionDate,
    TransactionType,
    Amount,
    CurrencyCode,
    Status,
    ReferenceCode
INTO #Q1After
FROM m2.FinancialTransactions
WHERE TransactionDate >= '2026-06-01'
  AND TransactionDate < '2026-07-01'
  AND CurrencyCode = 'USD'
  AND Status = 'Posted';
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Query 2 AFTER: window function running total
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q2After;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

WITH PostedTransactions AS (
    SELECT
        t.TransactionID,
        t.AccountID,
        t.TransactionDate,
        t.Amount,
        SUM(t.Amount) OVER (
            PARTITION BY t.AccountID
            ORDER BY t.TransactionDate, t.TransactionID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningPostedAmount
    FROM m2.FinancialTransactions AS t
    WHERE t.Status = 'Posted'
)
SELECT TOP 500
    cp.CounterpartyName,
    a.AccountNumber,
    pt.TransactionDate,
    pt.TransactionID,
    pt.Amount,
    pt.RunningPostedAmount
INTO #Q2After
FROM PostedTransactions AS pt
INNER JOIN m2.Accounts AS a
    ON pt.AccountID = a.AccountID
INNER JOIN m2.Counterparties AS cp
    ON a.CounterpartyID = cp.CounterpartyID
ORDER BY
    a.AccountNumber,
    pt.TransactionDate,
    pt.TransactionID;
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Query 3 AFTER: filter before grouping
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q3After;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT
    CurrencyCode,
    COUNT(*) AS PostedTransactionCount,
    SUM(Amount) AS PostedAmount
INTO #Q3After
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
GROUP BY CurrencyCode;
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Query 4 AFTER: direct predicate on filtered column
-- ------------------------------------------------------------
DROP TABLE IF EXISTS #Q4After;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SET STATISTICS XML ON;
GO

SELECT TOP 500
    TransactionID,
    AccountID,
    TransactionDate,
    Amount,
    CurrencyCode,
    Status
INTO #Q4After
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
ORDER BY TransactionDate DESC;
GO

SET STATISTICS XML OFF;
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO

-- ------------------------------------------------------------
-- Row-count check
-- ------------------------------------------------------------
SELECT
    'Q1 Before' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q1Before
UNION ALL
SELECT
    'Q1 After' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q1After
UNION ALL
SELECT
    'Q2 Before' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q2Before
UNION ALL
SELECT
    'Q2 After' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q2After
UNION ALL
SELECT
    'Q3 Before' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q3Before
UNION ALL
SELECT
    'Q3 After' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q3After
UNION ALL
SELECT
    'Q4 Before' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q4Before
UNION ALL
SELECT
    'Q4 After' AS QueryVersion,
    COUNT(*) AS RowsReturned
FROM #Q4After;
GO
