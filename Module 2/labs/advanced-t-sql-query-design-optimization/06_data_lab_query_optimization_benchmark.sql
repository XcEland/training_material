-- ============================================================
-- MODULE 2 DATA LAB
-- FILE 06: QUERY OPTIMIZATION BENCHMARK
-- ============================================================

USE TrainingDB;
GO

-- Data Lab goal:
-- 1. Run poor queries.
-- 2. Capture elapsed time and row counts.
-- 3. Apply an index or rewrite.
-- 4. Re-run and compare.
-- 5. Complete optimization_findings_template.md.

IF OBJECT_ID('m2.OptimizationBenchmark', 'U') IS NULL
BEGIN
    CREATE TABLE m2.OptimizationBenchmark (
        BenchmarkID INT IDENTITY(1,1) PRIMARY KEY,
        QueryName VARCHAR(100) NOT NULL,
        QueryVersion VARCHAR(30) NOT NULL,
        RowsReturned INT NOT NULL,
        ElapsedMs INT NOT NULL,
        Notes VARCHAR(300) NOT NULL,
        CapturedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
GO

TRUNCATE TABLE m2.OptimizationBenchmark;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ------------------------------------------------------------
-- Query 1 BEFORE: non-sargable date filter and SELECT *
-- ------------------------------------------------------------
DECLARE @StartTime DATETIME2 = SYSDATETIME();

DROP TABLE IF EXISTS #Q1Before;

SELECT *
INTO #Q1Before
FROM m2.FinancialTransactions
WHERE YEAR(TransactionDate) = 2026
  AND MONTH(TransactionDate) = 6
  AND CurrencyCode = 'USD'
  AND Status = 'Posted';

INSERT INTO m2.OptimizationBenchmark
    (QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes)
SELECT
    'Q1 June USD posted transactions',
    'Before',
    COUNT(*),
    DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME()),
    'Non-sargable YEAR/MONTH filter and SELECT *'
FROM #Q1Before;
GO

-- Apply optimisation: index plus sargable date range and selected columns.
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_M2_FinancialTransactions_DateCurrencyStatus'
      AND object_id = OBJECT_ID('m2.FinancialTransactions')
)
BEGIN
    CREATE INDEX IX_M2_FinancialTransactions_DateCurrencyStatus
    ON m2.FinancialTransactions (TransactionDate, CurrencyCode, Status)
    INCLUDE (TransactionID, AccountID, TransactionType, Amount, ReferenceCode);
END;
GO

DECLARE @StartTime DATETIME2 = SYSDATETIME();

DROP TABLE IF EXISTS #Q1After;

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

INSERT INTO m2.OptimizationBenchmark
    (QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes)
SELECT
    'Q1 June USD posted transactions',
    'After',
    COUNT(*),
    DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME()),
    'Sargable date range, selected columns, supporting index'
FROM #Q1After;
GO

-- ------------------------------------------------------------
-- Query 2 BEFORE: repeated correlated running-total subquery.
-- ------------------------------------------------------------
DECLARE @StartTime DATETIME2 = SYSDATETIME();

DROP TABLE IF EXISTS #Q2Before;

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

INSERT INTO m2.OptimizationBenchmark
    (QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes)
SELECT
    'Q2 account running totals',
    'Before',
    COUNT(*),
    DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME()),
    'Correlated subquery recalculates a running total for many rows'
FROM #Q2Before;
GO

-- Query 2 AFTER: window function computes running totals in one pass.
DECLARE @StartTime DATETIME2 = SYSDATETIME();

DROP TABLE IF EXISTS #Q2After;

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

INSERT INTO m2.OptimizationBenchmark
    (QueryName, QueryVersion, RowsReturned, ElapsedMs, Notes)
SELECT
    'Q2 account running totals',
    'After',
    COUNT(*),
    DATEDIFF(MILLISECOND, @StartTime, SYSDATETIME()),
    'Window function computes running totals without repeated subqueries'
FROM #Q2After;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

SELECT
    QueryName,
    QueryVersion,
    RowsReturned,
    ElapsedMs,
    Notes,
    CapturedAt
FROM m2.OptimizationBenchmark
ORDER BY QueryName, QueryVersion DESC;
GO

-- Learner task:
-- Use the Messages tab for logical reads and CPU time.
-- Use the Actual Execution Plan for operator changes.
-- Record the findings in optimization_findings_template.md.
