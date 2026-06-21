-- ============================================================
-- MODULE 2 LAB
-- FILE 04: MERGE, TABLE EXPRESSIONS, AND BULK-STYLE OPERATIONS
-- ============================================================

USE TrainingDB;
GO

-- 1. Review staging rows before loading.
SELECT *
FROM m2.StagingTransactions
ORDER BY ReferenceCode;
GO

-- 2. MERGE staging data into the transaction table.
DECLARE @MergeResults TABLE (
    MergeAction VARCHAR(10),
    ReferenceCode VARCHAR(40),
    TransactionID BIGINT NULL
);

WITH CleanStage AS (
    SELECT
        s.ReferenceCode,
        a.AccountID,
        s.TransactionDate,
        s.ValueDate,
        s.TransactionType,
        s.Amount,
        s.CurrencyCode,
        s.Channel,
        s.Status
    FROM m2.StagingTransactions AS s
    INNER JOIN m2.Accounts AS a
        ON s.AccountNumber = a.AccountNumber
    WHERE s.Amount > 0
)
MERGE m2.FinancialTransactions AS target
USING CleanStage AS source
    ON target.ReferenceCode = source.ReferenceCode
WHEN MATCHED THEN
    UPDATE SET
        target.AccountID = source.AccountID,
        target.TransactionDate = source.TransactionDate,
        target.ValueDate = source.ValueDate,
        target.TransactionType = source.TransactionType,
        target.Amount = source.Amount,
        target.CurrencyCode = source.CurrencyCode,
        target.Channel = source.Channel,
        target.Status = source.Status
WHEN NOT MATCHED THEN
    INSERT
        (AccountID, TransactionDate, ValueDate, TransactionType, Amount, CurrencyCode, Channel, Status, ReferenceCode)
    VALUES
        (source.AccountID, source.TransactionDate, source.ValueDate, source.TransactionType, source.Amount, source.CurrencyCode, source.Channel, source.Status, source.ReferenceCode)
OUTPUT
    $action,
    inserted.ReferenceCode,
    inserted.TransactionID
INTO @MergeResults;

SELECT *
FROM @MergeResults
ORDER BY ReferenceCode;
GO

-- 3. Table expression: prepare monthly totals before loading a summary table.
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

TRUNCATE TABLE m2.MonthlyTransactionSummary;
GO

-- 4. Bulk-style INSERT ... SELECT from a table expression.
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

SELECT *
FROM m2.MonthlyTransactionSummary
ORDER BY SummaryMonth, CurrencyCode;
GO
