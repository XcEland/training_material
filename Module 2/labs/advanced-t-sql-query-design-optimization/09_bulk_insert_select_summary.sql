-- ============================================================
-- MODULE 2 LAB
-- FILE 09: BULK-STYLE INSERT SELECT SUMMARY LOAD
-- ============================================================

USE TrainingDB;
GO

-- Notes:
-- INSERT ... SELECT is the core pattern behind many database load jobs.
-- The SELECT result defines the shape of the rows loaded into the summary table.

-- 1. Preview the monthly summary result before loading it.
SELECT
    DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS SummaryMonth,
    CurrencyCode,
    COUNT(*) AS PostedTransactionCount,
    SUM(Amount) AS PostedAmount
FROM m2.FinancialTransactions
WHERE Status = 'Posted'
GROUP BY
    DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1),
    CurrencyCode
ORDER BY SummaryMonth, CurrencyCode;
GO

-- 2. Create the destination summary table.
IF OBJECT_ID('m2.MonthlyTransactionSummary', 'U') IS NULL
BEGIN
    CREATE TABLE m2.MonthlyTransactionSummary (
        SummaryMonth DATE NOT NULL,
        CurrencyCode CHAR(3) NOT NULL,
        PostedTransactionCount INT NOT NULL,
        PostedAmount DECIMAL(18,2) NOT NULL,
        LoadedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_M2_MonthlyTransactionSummary
            PRIMARY KEY (SummaryMonth, CurrencyCode)
    );
END;
GO

-- 3. Clear old lab output so the load is repeatable.
TRUNCATE TABLE m2.MonthlyTransactionSummary;
GO

-- 4. Bulk-style INSERT ... SELECT from a CTE.
WITH MonthlyTotals AS (
    SELECT
        DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1) AS SummaryMonth,
        CurrencyCode,
        COUNT(*) AS PostedTransactionCount,
        SUM(Amount) AS PostedAmount
    FROM m2.FinancialTransactions
    WHERE Status = 'Posted'
    GROUP BY
        DATEFROMPARTS(YEAR(TransactionDate), MONTH(TransactionDate), 1),
        CurrencyCode
)
INSERT INTO m2.MonthlyTransactionSummary
    (SummaryMonth, CurrencyCode, PostedTransactionCount, PostedAmount)
SELECT
    SummaryMonth,
    CurrencyCode,
    PostedTransactionCount,
    PostedAmount
FROM MonthlyTotals;
GO

-- 5. Verify loaded summary rows.
SELECT *
FROM m2.MonthlyTransactionSummary
ORDER BY SummaryMonth, CurrencyCode;
GO
